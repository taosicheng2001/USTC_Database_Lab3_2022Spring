-- 0 -not start
-- 1 -paying
-- 2 -finish
-- Make a Loan
DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
*/
Drop PROCEDURE IF EXISTS Make_Loan;
Create PROCEDURE Make_Loan(IN client_id char(18), IN sb_name VarCHAR(20), IN loan_sum Decimal(20,6))
BEGIN
   DECLARE s INT DEFAULT 0;
   DECLARE state INT DEFAULT 0;
   DECLARE cur_loan_id char(20);
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
   START TRANSACTION;

   Select Max(loan_id) From Loan INTO cur_loan_id;

   -- no data
    IF cur_loan_id is NULL THEN
        Set cur_loan_id = 0;
    ELSE
        Set cur_loan_id = cur_loan_id + 1;
    END IF;

   -- INSERT INTO LOAN
   INSERT INTO Loan
   VALUES(cur_loan_id, sb_name,loan_sum, 0);

   -- INSERT INTO OWNLOAN
   INSERT INTO Own_Loan
   VALUES(client_id,cur_loan_id);

   IF s = 0 THEN
      SET state = 0;
      COMMIT;
   ELSE
      SET state = s;
      ROLLBACK;
   END IF;

   UPDATE State
      Set State.state = state;
END   //

DELIMITER ;


DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
   state = 3 贷款正在发放
*/
DROP PROCEDURE IF EXISTS Del_Loan;
CREATE PROCEDURE Del_Loan(IN loan_id VarChar(20))
BEGIN
   DECLARE s INT DEFAULT 0;
   DECLARE cur_state INT DEFAULT 0;
   DECLARE state INT DEFAULT 0;
   DECLARE tmp VarChar(20);
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
   START TRANSACTION;

   Set state = 0;

   -- IF EXiSTS loan_id
   Select loan_id From Loan
      Where Loan.loan_id = loan_id
      INTO tmp;

   -- remove FK-check
   SET foreign_key_checks = 0;
   
   -- Del
   SELECT loan_state From Loan Where Loan.loan_id = loan_id INTO cur_state;

   IF cur_state = 1  THEN
      Set state = 3;
   ELSE
      Delete From Loan
         Where Loan.loan_id = loan_id;
      Delete From Pay
         Where Pay.loan_id = loan_id;
      Delete From Own_Loan
         Where Own_Loan.loan_id = loan_id;
   END IF;

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

END   //