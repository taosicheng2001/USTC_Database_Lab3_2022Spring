-- Make Payment
DELIMITER //
/*
   state = 0 正常执行
   state = 1 未找到key
   state = 2 其他SQL错误
   state = 3 超出应付款项
*/

DROP PROCEDURE IF EXISTS Make_Payment;
CREATE PROCEDURE Make_Payment(IN sb_name VARCHAR(20), IN loan_id CHAR(20), IN pay_sum Decimal(20,6),IN pay_date date)
BEGIN
   DECLARE s INT DEFAULT 0;
   DECLARE state INT DEFAULT 0;
   DECLARE cur_sum double DEFAULT 0;
   DECLARE total_sum double DEFAULT 0;
   DECLARE cur_pay_order INT DEFAULT 0;
   DECLARE tmp VarCHar(20);
   DECLARE flag INT DEFAULT 0;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;
   START TRANSACTION;

   -- IF EXiSTS loan_id
   Select loan_id From Loan
      Where Loan.loan_id = loan_id
      INTO tmp;

   -- get next pay_order
   Select Max(pay_order) From Pay Where Pay.loan_id = loan_id INTO cur_pay_order;
   IF cur_pay_order IS NULL THEN
      Set cur_pay_order = 1;
   ELSE
      Set cur_pay_order = cur_pay_order + 1;
   END IF;

   -- get avaliable remain
   Select Sum_Payment(loan_id) INTO cur_sum;
   IF cur_sum is NULL THEN
      Set cur_sum = 0;
   END IF;

   Select loan_sum From Loan where Loan.loan_id = loan_id INTO total_sum;

   -- Insert
   IF pay_sum + cur_sum > total_sum THEN
      SET state = 3;
   ELSE
      INSERT INTO Pay
      VALUES(loan_id,cur_pay_order,sb_name,pay_sum,pay_date);

      IF pay_sum  + cur_sum = total_sum THEN
         Set flag = 1;
      ELSE
         Set flag = 0;
      END IF;


      IF flag = 1 THEN
         UPDATE Loan
            Set loan_state = 2
            Where Loan.loan_id = loan_id;
      ELSE
         UPDATE Loan
            Set loan_state = 1
            Where Loan.loan_id = loan_id;      
      END IF;
   END IF;

   -- check
   IF s = 0 THEN
      COMMIT;
   ELSE
      Set state = s;
      ROLLBACK;
   END IF;    

   Update State
      Set State.state = state;
END //