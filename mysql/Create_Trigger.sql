DELIMITER //

DROP TRIGGER IF EXISTS LoanModifyForBidden;
CREATE Trigger LoanModifyForBidden
Before Update
ON Loan
For Each Row
BEGIN
    DECLARE cur_sum double DEFAULT 0;
    DECLARE flag INT DEFAULT 0;

    SET NEW.loan_id = OLD.loan_id;
    SET NEW.sb_name = OLD.sb_name;
    SET NEW.loan_sum = OLD.loan_sum;

    Select Sum_Payment(NEW.loan_id) INTO cur_sum;
    IF cur_sum IS NULL  THEN
        Set cur_sum = 0;
    END IF;
    
    Select Double_Equal(cur_sum,NEW.loan_sum) INTO flag;
    
    IF flag = 1 THEN
        SET NEW.loan_state = 2;
    ELSE
        SET NEW.loan_sum = OLD.loan_sum;
    END IF;

END //
DELIMITER ;


DROP TRIGGER IF EXISTS AccountIDModifyForBidden_ACC;
CREATE Trigger AccountIDModifyForBidden_ACC
Before Update
ON Accounts
For Each Row
BEGIN
    SET NEW.account_id = OLD.account_id;
    SET NEW.create_account_date = OLD.create_account_date;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS AccountIDModifyForBidden_ST_ACC;
CREATE Trigger AccountIDModifyForBidden_ST_ACC
Before Update
ON Storage_Account
For Each Row
BEGIN
    SET NEW.account_id = OLD.account_id;
END //

DELIMITER ;

DROP TRIGGER IF EXISTS AccountIDModifyForBidden_CK_ACC;
CREATE Trigger AccountIDModifyForBidden_CK_ACC
Before Update
ON Check_Account
For Each Row
BEGIN
    SET NEW.account_id = OLD.account_id;
END //


DROP TRIGGER IF EXISTS ClientIDModifyForBidden;
CREATE Trigger ClientIDModifyForBidden
Before Update
ON Client
For Each Row
BEGIN
    SET NEW.client_id = OLD.client_id;
END //