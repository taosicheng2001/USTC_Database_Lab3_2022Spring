DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
   state = 3 超过账户数量限制
*/

DROP PROCEDURE IF EXISTS Create_Storage_Account;
CREATE PROCEDURE Create_Storage_Account(IN client_id Char(18), IN sb_name VarChar(20), IN balance Decimal(20,6), IN benefit_rate double , IN money_type VarChar(10), In create_date date)
BEGIN
    -- initial setting
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE flag INT;
    DECLARE cur_account_id Char(20);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;
    
    -- get next account id
    Select Max(account_id) From Accounts INTO cur_account_id;
    IF cur_account_id IS NULL THEN
        Set cur_account_id = 0;
    ELSE 
        Set cur_account_id = cur_account_id + 1;
    END IF;

    -- Insert Into Accounts
    INSERT INTO Accounts
    VALUES(cur_account_id,balance,sb_name,create_date);

    -- Insert Into Storage_Account
    INSERT INTO Storage_Account
    VALUES(cur_account_id,benefit_rate,money_type);

    -- Insert Into Own_Account
    INSERT INTO Own_Account
    VALUES(client_id,cur_account_id,create_date);

    -- check
    IF s = 0 THEN
        Select InValid_Account(client_id,sb_name) INTO flag;
        IF flag = 0 THEN
            SET state = 0;
            COMMIT;
        ELSE
            SET state = 3;
            ROLLBACK;
        END IF;
    ELSE
      SET state = s;
      ROLLBACK;
    END IF;

    UPDATE State
      Set State.state = state;

END //


DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
   state = 3 超过账户数量限制
*/
DROP PROCEDURE IF EXISTS Create_Check_Account;
CREATE PROCEDURE Create_Check_Account(IN client_id Char(18), IN sb_name VarChar(20), IN balance Decimal(20,6), IN credit_line Decimal(20,6), In create_date date)
BEGIN
    -- initial setting
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE cur_account_id VarChar(20);
    DECLARE flag INT;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;
    
    -- get next account id
    Select Max(account_id) From Accounts INTO cur_account_id;
    IF cur_account_id IS NULL THEN
        Set cur_account_id = 0;
    ELSE 
        Set cur_account_id = cur_account_id + 1;
    END IF;

    -- Insert Into Accounts
    Insert INTO Accounts
    VALUES(cur_account_id,balance,sb_name,create_date);

    -- Insert Into Check_Account
    Insert INTO Check_Account
    VALUES(cur_account_id,credit_line);

    -- Insert Into Own_Account
    INsert INTO Own_Account
    VALUES(client_id,cur_account_id,create_date);

    -- check
    IF s = 0 THEN
        Select InValid_Account(client_id,sb_name) INTO flag;
        IF flag = 0 THEN
            SET state = 0;
            COMMIT;
        ELSE
            SET state = 3;
            ROLLBACK;
        END IF;
    ELSE
      SET state = s;
      ROLLBACK;
    END IF;

    UPDATE State
      Set State.state = state;

END //

DELIMITER ;


DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
*/

DROP PROCEDURE IF EXISTS Del_Account;
CREATE PROCEDURE Del_Account(IN account_id VarChar(20))
BEGIN
   -- initial 
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp VarChar(20);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- If exists account
    Select account_id From Accounts
        Where Accounts.account_id = account_id
        INTO tmp;

    -- remove FK-check
    SET foreign_key_checks = 0;

    -- Del
    Delete From Storage_Account
        Where Storage_Account.account_id = account_id;
    Delete From Check_Account
        Where Check_Account.account_id = account_id; 
    Delete From Own_Account
        Where Own_Account.account_id = account_id;    
    Delete From Accounts
        Where Accounts.account_id = account_id;


    -- add FK-check
    SET foreign_key_checks = 1;  

       -- check
    IF s = 0 THEN
        COMMIT;
    ELSE
        Set state = s;
        ROLLBACK;
    END IF;

    UPDATE State
        Set State.state = state; 

END //

DELIMITER ;
DELIMITER //

/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
   state = 3 超过账户数量限制
*/
DROP PROCEDURE IF EXISTS Migration_Account;
CREATE PROCEDURE Migration_Account(IN account_id VarChar(20),IN sb_name Varchar(20))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE flag INT DEFAULT 0;
    DECLARE tmp VarChar(20);
    DECLARE cur_client_id Char(18);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- If exists account
    Select account_id From Accounts
        Where Accounts.account_id = account_id
        INTO tmp;

    UPDATE Accounts
        Set Accounts.sb_name = sb_name
        Where Accounts.account_id = account_id;
    
    Select client_id From Own_Account
        Where Own_Account.account_id = account_id
        INTO cur_client_id;

    -- CHECK
    IF s = 0 THEN
        Select InValid_Account(cur_client_id,sb_name) INTO flag;
        IF flag = 0 THEN
            SET state = 0;
            COMMIT;
        ELSE
            SET state = 3;
            ROLLBACK;
        END IF;
    ELSE
      SET state = s;
      ROLLBACK;
    END IF;
    
    UPDATE State
        Set State.state = state; 

END //

DELIMITER ;


DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key,账户类型错误
   state = 2 其他SQL错误
*/
DROP PROCEDURE IF EXISTS Modify_Storage_Account;
Create PROCEDURE Modify_Storage_Account(IN client_id Char(18),IN account_id Varchar(20), IN balance Decimal(20,6),IN benefit_rate double, IN money_type VarChar(10))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp INT;
    DECLARE cur_account_id Varchar(20);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- If exists account
    Select account_id From Accounts
        Where Accounts.account_id = account_id
        INTO tmp;

    Select account_id From Storage_Account    
        Where   Storage_Account.account_id = account_id INTO cur_account_id;

    IF cur_account_id IS NULL THEN
        Set state = 3;
    END IF;

    IF balance IS NOT NULL  THEN
        UPDATE Accounts
            Set Accounts.balance = balance
            Where  Accounts.account_id = account_id;
    END IF;

    UPDATE Own_Account
        Set Own_Account.last_access_date = curdate()
        Where  Own_Account.account_id = account_id and Own_Account.client_id = client_id;

    IF benefit_rate IS NOT NULL THEN
        UPDATE Storage_Account
            Set Storage_Account.benefit_rate = benefit_rate
            Where Storage_Account.account_id = account_id;
    END IF;
    
    IF money_type IS NOT NULL THEN
        UPDATE Storage_Account
            Set Storage_Account.money_type = money_type
            Where Storage_Account.account_id = account_id;
    END IF;
    
    -- check
    IF s = 0 THEN
        IF state = 3 THEN
            ROLLBACK;
        ELSE
            Set state = 0;
            COMMIT;
        END IF;
    ELSE
        Set state = s;
        ROLLBACK;
    END IF;

    UPDATE State
        Set State.state = state; 

END //

DELIMITER ;


DELIMITER //

/*
   state = 0 正常执行
   state = 1 未找到key,账户类型错误
   state = 2 其他SQL错误
*/
DROP PROCEDURE IF EXISTS Modify_Check_Account;
Create PROCEDURE Modify_Check_Account(IN client_id Char(18) , IN account_id Varchar(20), IN balance Decimal(20,6), IN credit_line Decimal(20,6))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp INT;
    DECLARE cur_account_id Varchar(20);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- If exists account
    Select account_id From Accounts
        Where Accounts.account_id = account_id
        INTO tmp;

    Select account_id From Check_Account    
        Where  Check_Account.account_id = account_id INTO cur_account_id;

    IF cur_account_id IS NULL THEN
        Set state = 3;
    END IF;

    IF balance IS NOT NULL THEN
        UPDATE Accounts
            Set Accounts.balance = balance
            Where  Accounts.account_id = account_id;
    END IF;

    UPDATE Own_Account
        Set Own_Account.last_access_date = curdate()
        Where  Own_Account.account_id = account_id and Own_Account.client_id = client_id;

    IF credit_line IS NOT NULL THEN
        UPDATE Check_Account
            Set Check_Account.credit_line = credit_line
            Where Check_Account.account_id = account_id;
    END IF;
    
    IF s = 0 THEN
        IF state = 3 THEN
            ROLLBACK;
        ELSE
            Set state = 0;
            COMMIT;
        END IF;
    ELSE
        Set state = s;
        ROLLBACK;
    END IF;

    UPDATE State
        Set State.state = state; 

END //