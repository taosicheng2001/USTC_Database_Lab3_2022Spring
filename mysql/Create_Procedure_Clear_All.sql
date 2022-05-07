DELIMITER //

DROP PROCEDURE IF EXISTS Clear_All;
CREATE PROCEDURE Clear_All()
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
    START TRANSACTION;

    -- remove constraint
    SET foreign_key_checks = 0;
    SET @disable_triggers = 1;

    Delete From Own_Account;
    Delete From Own_Loan;
    Delete From Accounts;
    Delete From Storage_Account;
    Delete From Check_Account;
    Delete From Loan;
    Delete From Pay;
    Delete From Connect;

    -- readd constraint
    SET foreign_key_checks = 1;
    SET @disable_triggers = NULL;

    -- check
    IF s = 0 THEN
        Set state = 0;
        COMMIT;
    ELSE
        Set state = s;
        ROLLBACK;
    END IF;

    UPDATE State
        Set State.state = state; 

END //