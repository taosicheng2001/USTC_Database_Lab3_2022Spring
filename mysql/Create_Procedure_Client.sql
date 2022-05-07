/*
    用户管理系统相关存储过程
    陶思成 2022.5.6
*/

/*
    创建客户
    state = 0 正常执行
    state = 1 未找到key
    state = 2 其他SQL错误
*/
*/
DELIMITER //
DROP PROCEDURE IF EXISTS Create_Client;
CREATE PROCEDURE Create_Client(IN client_id Char(18),IN client_name Char(10),IN client_pn DECIMAL(11,0),IN client_addr Varchar(50), IN connector_name VarChar(10),IN connector_pn DECIMAL(11,0),IN connector_email VarChar(30),IN relationship Varchar(20))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- Insert Into Client 
    Insert INTO Client
    VALUES(client_id,client_name,client_pn,client_addr,connector_name,connector_pn,connector_email,relationship);

    -- Check
    IF s = 0 THEN
        SET state = 0;
        COMMIT;
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
    删除客户
    state = 0 正常执行
    state = 1 未找到key
    state = 2 其他SQL错误
    state = 3 拥有账户或贷款
*/
DROP PROCEDURE IF EXISTS Del_Client;
CREATE PROCEDURE Del_Client(IN client_id Char(18))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE flag INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp Char(18);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- whether EXISTS
    Select client_id From Client
        Where Client.client_id = client_id
        INTO tmp;
    IF tmp IS NULL THEN
        Set flag = 2;
    END IF;


    -- Whether We Can Delete
    IF flag = 0 && EXISTS( Select Own_Account.client_id From Own_Account
        Where Own_Account.client_id = client_id)    THEN
            Set flag = 1;
    END IF;    

    IF flag = 0 && EXISTS( Select Own_Loan.client_id From Own_Loan 
        Where Own_Loan.client_id = client_id)   THEN
            Set flag = 1;
    END IF;

    -- IF We can Delete
    IF flag = 0 THEN

        -- remove FK-check
        SET foreign_key_checks = 0;

        DELETE From Connect
            Where Connect.client_id = client_id;
        
        Delete From Client
            Where Client.client_id = client_id;

        -- add FK-check
        SET foreign_key_checks = 1;

    END IF;

    IF s = 0 THEN
        IF flag = 1 THEN
            Set state = 3;
            ROLLBACK;
        ELSE
            IF flag = 2 THEN
                Set state = 2;
                ROLLBACK;
            ELSE
                Set state = 0;
                COMMIT;
            END IF;
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
    修改客户
    state = 0 正常执行
    state = 1 未找到key
    state = 2 其他SQL错误
*/
DROP PROCEDURE IF EXISTS Modify_Client;
CREATE PROCEDURE Modify_Client(IN client_id Char(18), IN client_name VarChar(10), IN client_pn DECIMAL(11,0),IN client_addr VarChar(50),IN connector_name VarChar(10), IN connector_pn DECIMAL(11,0),IN connector_email VarChar(30), IN relationship VarChar(20))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp Char(18);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;
    
    -- whether EXISTS
    Select client_id From Client
        Where Client.client_id = client_id
        INTO tmp;

    IF client_name IS NOT NULL THEN
        Update  Client 
            Set Client.client_name = client_name
            Where Client.client_id = client_id;
    END IF; 

    IF client_pn IS NOT NULL THEN
        Update  Client 
            Set Client.client_pn = client_pn
            Where Client.client_id = client_id;
    END IF; 

    IF client_addr IS NOT NULL THEN
        Update  Client 
            Set Client.client_addr = client_addr
            Where Client.client_id = client_id;
    END IF; 

    IF connector_name IS NOT NULL THEN
        Update  Client 
            Set Client.connector_name = connector_name
            Where Client.client_id = client_id;
    END IF; 

    IF connector_pn IS NOT NULL THEN
        Update  Client 
            Set Client.connector_pn = connector_pn
            Where Client.client_id = client_id;
    END IF; 

    IF connector_email IS NOT NULL THEN
        Update  Client 
            Set Client.connector_email = connector_email
            Where Client.client_id = client_id;
    END IF; 

    IF relationship IS NOT NULL THEN
        Update  Client 
            Set Client.relationship = relationship
            Where Client.client_id = client_id;
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
    修改客户
    state = 0 正常执行
    state = 1 未找到key
    state = 2 其他SQL错误
*/

DROP PROCEDURE IF EXISTS Del_Connection;
CREATE PROCEDURE Del_Connection(IN client_id Char(18), IN worker_id Char(18))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp1 Char(18);
    DECLARE tmp2 Char(18);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- IF EXISTS
    Select  client_id , worker_id From Connect Where Connect.client_id = client_id
                and Connect.worker_id = worker_id INTO tmp1,tmp2;

    -- do
    IF EXISTS(Select client_id , worker_id From Connect Where Connect.client_id = client_id
                and Connect.worker_id = worker_id) THEN
        Delete From Connect
            Where Connect.client_id = client_id and Connect.worker_id = worker_id;    

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
DROP PROCEDURE IF EXISTS Modify_Connection;
CREATE PROCEDURE Modify_Connection(IN client_id Char(18), IN worker_id Char(18), IN connect_type VarChar(15))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp1 Char(18);
    DECLARE tmp2 Char(18);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- do
    IF EXISTS(Select client_id , worker_id From Connect Where Connect.client_id = client_id
                and Connect.worker_id = worker_id) THEN
        Update Connect
            Set Connect.connect_type = connect_type
            Where Connect.client_id = client_id and Connect.worker_id = worker_id;
    ELSE
        Insert INTO Connect
        VALUES(client_id,worker_id,connect_type);
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