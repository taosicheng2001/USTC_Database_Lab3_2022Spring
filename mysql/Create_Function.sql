-- 余款查询函数
DELIMITER //
DROP FUNCTION IF EXISTS Sum_Payment;
Create Function Sum_Payment(loan_id CHAR(20))
RETURNS Double
READS SQL DATA
BEGIN
   DECLARE s INT DEFAULT 0;
   DECLARE sum double DEFAULT 0;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;

   Select SUM(pay_sum) From Pay Where Pay.loan_id = loan_id INTO sum;

   IF s = 0 THEN
      RETURN sum;
   ELSE
      Set sum  = -1;
      RETURN sum;
   END IF;
END //
DELIMITER ; 


-- Double 相等
DELIMITER //

/*
   Return 1 IF b-a < esp
   Return 0 IF Not
*/
DROP FUNCTION IF EXISTS Double_Equal;
CREATE Function Double_Equal(a double,b double)
RETURNS INT
NO SQL
BEGIN

   DECLARE esp double DEFAULT 0.00001;
   DECLARE val INT DEFAULT 0;
   IF b - a < esp THEN
      SET val = 1;
   ELSE
      Set val = 0;
   END IF;

   Return val;
END //

DELIMITER ;

DELIMITER //
-- 客户是否在某银行有超过要求的账户
/*
   Return 1 IF INVALID
   ELSE Return 0
*/

DROP FUNCTION IF EXISTS InValid_Account;
CREATE FUNCTION InValid_Account(client_id Char(18),sb_name VarChar(20))
RETURNS INT
Reads SQL Data
BEGIN
   DECLARE s INT DEFAULT 0;
   DECLARE flag INT DEFAULT 0;
   DECLARE check_account_num INT DEFAULT 0;
   DECLARE storage_account_num INT DEFAULT 0;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;

   -- get how many storage account client have in sb
   Select COUNT(*) From Own_Account,Storage_Account,Accounts
      Where Own_Account.account_id = Storage_Account.account_id and 
         Accounts.sb_name = sb_name and Own_Account.client_id = client_id 
         and Accounts.account_id = Storage_Account.account_id
      INTO storage_account_num;

   Select COUNT(*) From Own_Account,Check_Account,Accounts
      Where Own_Account.account_id = Check_Account.account_id and 
         Accounts.sb_name = sb_name and Own_Account.client_id = client_id
         and Accounts.account_id = Check_Account.account_id
      INTO check_account_num;

   IF storage_account_num IS NULL THEN
      Set storage_account_num = 0;
   END IF;

   IF check_account_num IS NULL THEN
      Set check_account_num = 0;
   END IF;

   -- more than three invalid
   IF check_account_num > 1 THEN
      Set flag = 1;
   END IF;

   IF storage_account_num > 1 THEN
      Set flag = 1;
   END IF;

   Return flag;

END   //
