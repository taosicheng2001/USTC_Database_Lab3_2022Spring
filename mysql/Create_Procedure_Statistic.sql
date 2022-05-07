DELIMITER ;

/* 储蓄业务数据统计 按年分组 （前100条） */
Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number , SB.sb_name ,date_format(Own_Account.last_access_date, '%Y')  As year
    FROM Accounts,Storage_Account,Own_Account,SB
    Where Storage_Account.account_id = Accounts.account_id and 
        Storage_Account.account_id = Own_Account.account_id and
        Accounts.sb_name = SB.sb_name
    GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y')
    ORDER BY year DESC
    LIMIT 100;

/* 储蓄业务数据统计 按月分组 （前100条）*/
Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
    FROM Accounts,Storage_Account,Own_Account,SB
    Where Storage_Account.account_id = Accounts.account_id and 
        Storage_Account.account_id = Own_Account.account_id and
        Accounts.sb_name = SB.sb_name
    GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
    ORDER BY month DESC
    LIMIT 100;

/* 储蓄业务数据统计 按季度分组（前100条） */
Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)  As quarter 
    FROM Accounts,Storage_Account,Own_Account,SB
    Where Storage_Account.account_id = Accounts.account_id and 
        Storage_Account.account_id = Own_Account.account_id and
        Accounts.sb_name = SB.sb_name
    GROUP BY SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)
    ORDER BY quarter DESC
    LIMIT 100;

/* 储蓄业务数据统计 指定参数进行查询 （前100条） */
/*
    service_type 0 : Storage
    service_type 1 : Loan

    time_type 0 : Year
    time_type 1 : Month
    time_type 2 : quarter   

    sb_name NULL : All Bank
    sb_name NOT NULL : One Bank

    cut_type 0 : year
    cut_type 1 : month
    cut_type 2 : quarter
*/
DELIMITER //


DROP PROCEDURE IF EXISTS Statistic_Storage_All_Year;
CREATE PROCEDURE Statistic_Storage_All_Year()
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;

    Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number , SB.sb_name ,date_format(Own_Account.last_access_date, '%Y')  As year
    FROM Accounts,Storage_Account,Own_Account,SB
    Where Storage_Account.account_id = Accounts.account_id and 
        Storage_Account.account_id = Own_Account.account_id and
        Accounts.sb_name = SB.sb_name
    GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y')
    ORDER BY year DESC
    LIMIT 100;

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

DROP PROCEDURE IF EXISTS Statistic_Storage;
CREATE PROCEDURE Statistic_Storage(IN time_type INT,IN cut_type INT ,IN time date ,IN sb_name VarChar(10))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp VarChar(10);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;

    -- Whether Bank EXISTS
    IF sb_name IS NOT NULL THEN
        Select sb_name From SB
            Where SB.sb_name = sb_name
            INTO tmp;
    END IF;
    

    CASE
        -- specific  year
        When time_type = 0 THEN
            -- specific sb
            IF sb_name IS NOT NULL THEN
                CASE
                    -- cut by year
                    When cut_type = 0 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y')  As  year
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y')
                        ORDER BY year DESC
                        LIMIT 100;
                    -- cut by month
                    When cut_type = 1 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                    ELSE
                    -- cut by quarter
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)  As quarter 
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            -- all sb
            ELSE
                CASE
                    -- cut by year
                    When cut_type = 0 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y')  As yaer
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y')
                        ORDER BY year DESC
                        LIMIT 100;
                    -- cut by month
                    When cut_type = 1 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name 
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                    ELSE
                    -- cut by quarter
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)  As quarter 
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name 
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            END IF;
        
        -- specific month
        When time_type = 1 THEN
            IF sb_name IS NOT NULL THEN
                CASE
                    When cut_type = 1 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Own_Account.last_access_date, '%Y-%m') = date_format(time, '%Y-%m')
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                END CASE;
            ELSE
                CASE
                    When cut_type = 1 THEN
                    Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
                    FROM Accounts,Storage_Account,Own_Account,SB
                    Where Storage_Account.account_id = Accounts.account_id and 
                        Storage_Account.account_id = Own_Account.account_id and
                        Accounts.sb_name = SB.sb_name
                        and date_format(Own_Account.last_access_date, '%Y-%m') = date_format(time, '%Y-%m')
                    GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
                    ORDER BY month DESC
                    LIMIT 100;
                END CASE;
            END IF;
        -- specific quarter
        When time_type = 2 THEN
            IF sb_name IS NOT NULL THEN
                CASE
                    -- cut by month
                    When cut_type = 1 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                            and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                    -- cut by quarter
                    WHEN cut_type = 2 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)  As quarter 
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                            and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                        GROUP BY SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            ELSE
                CASE
                    -- cut by month
                    When cut_type = 1 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name ,date_format(Own_Account.last_access_date, '%Y-%m')  As month
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                            and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                        GROUP BY SB.sb_name, date_format(Own_Account.last_access_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                    -- cut by quarter
                    When cut_type = 2 THEN
                        Select Sum(Accounts.balance) as sum, COUNT(DISTINCT Own_Account.client_id) as clients_number, SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)  As quarter 
                        FROM Accounts,Storage_Account,Own_Account,SB
                        Where Storage_Account.account_id = Accounts.account_id and 
                            Storage_Account.account_id = Own_Account.account_id and
                            Accounts.sb_name = SB.sb_name
                            and date_format(Own_Account.last_access_date, '%Y') = date_format(time, '%Y')
                            and Ceiling(date_format(Own_Account.last_access_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                        GROUP BY SB.sb_name, Ceiling(date_format(Own_Account.last_access_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            END IF;

    END CASE;


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

/* 贷款业务数据统计 按年分组 （前100条） */
Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y')  As year
    FROM Pay,Own_Loan,SB
    Where Pay.loan_id = Own_Loan.loan_id and 
        Pay.sb_name = SB.sb_name
    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y')
    ORDER BY year DESC
    LIMIT 100;

/* 贷款业务数据统计 按月分组 （前100条） */
Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
    FROM Pay,Own_Loan,SB
    Where Pay.loan_id = Own_Loan.loan_id and 
        Pay.sb_name = SB.sb_name
    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
    ORDER BY month DESC
    LIMIT 100;

/* 贷款业务数据统计 按季度分组 （前100条） */
Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name , Ceiling(date_format(Pay.pay_date,'%m')/3)  As quarter
    FROM Pay,Own_Loan,SB
    Where Pay.loan_id = Own_Loan.loan_id and 
        Pay.sb_name = SB.sb_name
    GROUP BY SB.sb_name, Ceiling(date_format(Pay.pay_date,'%m')/3)
    ORDER BY quarter DESC
    LIMIT 100;

DELIMITER //

DROP PROCEDURE IF EXISTS Statistic_Loan_All_Year;
CREATE PROCEDURE Statistic_Loan_All_Year()
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;

    Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y')  As year
    FROM Pay,Own_Loan,SB
    Where Pay.loan_id = Own_Loan.loan_id and 
        Pay.sb_name = SB.sb_name
    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y')
    ORDER BY year DESC
    LIMIT 100;

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


/* 贷款业务数据统计 指定参数进行查询 （前100条） */
/*
    time_type 0 : Year
    time_type 1 : Month
    time_type 2 : quarter

    sb_name NULL : All Bank
    sb_name NOT NULL : One Bank

    cut_type 0 : year
    cut_type 1 : month
    cut_type 2 : quarter
*/
DELIMITER //

DROP PROCEDURE IF EXISTS Statistic_Loan;
CREATE PROCEDURE Statistic_Loan(IN time_type INT,IN cut_type INT ,IN time date ,IN sb_name VarChar(10))
BEGIN
    DECLARE s INT DEFAULT 0;
    DECLARE state INT DEFAULT 0;
    DECLARE tmp VarChar(10);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET s = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET s = 2;

    -- Whether Bank EXISTS
    IF sb_name IS NOT NULL THEN
        Select sb_name From SB
            Where SB.sb_name = sb_name
            INTO tmp;
    END IF;

    CASE
        -- specific year
        When time_type = 0 THEN
            -- spesific sb
            IF sb_name IS NOT NULL  THEN
                CASE  
                    When cut_type = 0 THEN
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y')  As year
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y')
                        ORDER BY year DESC
                        LIMIT 100;
                    When cut_type = 1 THEN
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                    ELSE
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name , Ceiling(date_format(Pay.pay_date,'%m')/3)  As quarter
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name and SB.sb_name = sb_name
                            and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, Ceiling(date_format(Pay.pay_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            -- all sb
            ELSE
                CASE  
                    When cut_type = 0 THEN
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y')  As year
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name
                            and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y')
                        ORDER BY year DESC
                        LIMIT 100;                    
                    When cut_type = 1 THEN
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name
                            and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
                        ORDER BY month DESC
                        LIMIT 100;
                    ELSE
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name , Ceiling(date_format(Pay.pay_date,'%m')/3)  As quarter
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name
                            and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        GROUP BY SB.sb_name, Ceiling(date_format(Pay.pay_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            END IF;

        -- specific month
        When time_type = 1 THEN
            -- spesific sb
            IF sb_name IS NOT NULL  THEN
                IF cut_type = 1 THEN
                    Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
                    FROM Pay,Own_Loan,SB
                    Where Pay.loan_id = Own_Loan.loan_id and 
                        Pay.sb_name = SB.sb_name and SB.sb_name = sb_name
                        and date_format(Pay.pay_date, '%Y-%m') = date_format(time, '%Y-%m')
                    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
                    ORDER BY month DESC
                    LIMIT 100;
                END IF;
            -- all sb
            ELSE
                IF cut_type = 1 THEN
                    Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
                    FROM Pay,Own_Loan,SB
                    Where Pay.loan_id = Own_Loan.loan_id and 
                        Pay.sb_name = SB.sb_name
                        and date_format(Pay.pay_date, '%Y-%m') = date_format(time, '%Y-%m')
                    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
                    ORDER BY month DESC
                    LIMIT 100;
                END IF;
            END IF;     

        -- specific quarter
        ELSE
            -- specific sb
            IF sb_name IS NOT NULL THEN
                CASE 
                    When cut_type = 1 THEN
                    Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
                    FROM Pay,Own_Loan,SB
                    Where Pay.loan_id = Own_Loan.loan_id and 
                        Pay.sb_name = SB.sb_name and SB.sb_name = sb_name
                        and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
                    ORDER BY month DESC
                    LIMIT 100;
                    When cut_type = 2 THEN
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name , Ceiling(date_format(Pay.pay_date,'%m')/3)  As quarter
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name  and SB.sb_name = sb_name
                        and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                        GROUP BY SB.sb_name, Ceiling(date_format(Pay.pay_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            -- all sb    
            ELSE
                CASE 
                    When cut_type = 1 THEN
                    Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name ,date_format(Pay.pay_date, '%Y-%m')  As month
                    FROM Pay,Own_Loan,SB
                    Where Pay.loan_id = Own_Loan.loan_id and 
                        Pay.sb_name = SB.sb_name
                        and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                    GROUP BY SB.sb_name, date_format(Pay.pay_date, '%Y-%m')
                    ORDER BY month DESC
                    LIMIT 100;
                    When cut_type = 2 THEN
                        Select Sum(Pay.pay_sum) as sum, COUNT(DISTINCT Own_Loan.client_id) as clients_number , SB.sb_name , Ceiling(date_format(Pay.pay_date,'%m')/3)  As quarter
                        FROM Pay,Own_Loan,SB
                        Where Pay.loan_id = Own_Loan.loan_id and 
                            Pay.sb_name = SB.sb_name  and SB.sb_name = sb_name
                        and date_format(Pay.pay_date, '%Y') = date_format(time, '%Y')
                        and Ceiling(date_format(Pay.pay_date,'%m')/3) = Ceiling(date_format(time,'%m')/3)
                        GROUP BY SB.sb_name, Ceiling(date_format(Pay.pay_date,'%m')/3)
                        ORDER BY quarter DESC
                        LIMIT 100;
                END CASE;
            END IF;

    END CASE;

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