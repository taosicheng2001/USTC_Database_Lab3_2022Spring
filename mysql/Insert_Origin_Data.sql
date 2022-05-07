# 客户
Insert INTo Client
VALUES(360103100202122878,'涂申春',13629387162,'USTC X1 426','张琪琪',19303982318,'hymmgustc@163.com','朋友');
Insert into Client
Values(360102987329381730,'张二圆',13998365137,'USTC X2 312','谈方方',19309739271,'tff@mail.ustc.edu.cn','朋友');

# 支行
Insert INTO SB
VALUES('中国银行金寨路支行','合肥',1000000000);
Insert INTO SB
VALUES('中国银行八一大道支行','南昌',1200000000);
Insert INTO SB
VALUES('中国银行三里屯支行','北京',4000000000);
Insert INTO SB
VALUES('中国银行浦东支行','上海',3000000000);

# 部门
Insert INTO Department
VALUES('00001','中国银行金寨路支行','办公室',0);
Insert INTO Department
VALUES('00002','中国银行金寨路支行','财务部',1);
Insert INTO Department
VALUES('00003','中国银行金寨路支行','市场部',2);
Insert INTO Department
VALUES('00004','中国银行八一大道支行','办公室',0);
Insert INTO Department
VALUES('00005','中国银行八一大道支行','财务部',1);

# 员工
Insert Into Worker
VALUES('360111201323238880','00001','小花',13813728371,'合肥金寨路666号',date_format('2015-5-7','%Y-%m-%d'));
Insert Into Worker
VALUES('360111201932132880','00001','小黑',13983243349,'合肥金寨路776号',date_format('2014-9-6','%Y-%m-%d'));
Insert Into Worker
VALUES('360293816235123123','00002','小白',13302341832,'合肥金寨路722号',date_format('2016-3-3','%Y-%m-%d'));
Insert Into Worker
VALUES('361416463412313232','00003','小紫',13912317313,'合肥金寨路703号',date_format('2017-8-30','%Y-%m-%d'));
Insert Into Worker
VALUES('312332103283423462','00004','小绿',13099312311,'合肥金寨路777号',date_format('2019-10-11','%Y-%m-%d'));
Insert Into Worker
VALUES('360111201302391880','00005','小黑',13983726152,'合肥金寨路776号',date_format('2014-9-6','%Y-%m-%d'));

# 联系
Insert Into Connect
VALUES('360103100202122878','360111201932132880','银行账户负责人');
Insert Into Connect
VALUES('360103100202122878','360111201323238880','贷款负责人');
Insert Into Connect
VALUES('360102987329381730','360111201323238880','贷款负责人');




# 经理
Insert Into Manager
VALUES(360111201932132880,'00001');
Insert Into Manager
VALUES(360293816235123123,'00002');
Insert Into Manager
VALUES(361416463412313232,'00003');
Insert Into Manager
VALUES(312332103283423462,'00004');
Insert Into Manager
VALUES(360111201302391880,'00005');

# 账户
INSERT INTO Accounts
VALUES('00000000000000000001',20000,'中国银行金寨路支行',date_format('2019-7-10','%Y-%m-%d'));
INSERT INTO Accounts
VALUES('00000000000000000002',15000,'中国银行金寨路支行',date_format('2021-4-6','%Y-%m-%d'));
INSERT INTO Accounts
VALUES('00000000000000000003',5000,'中国银行八一大道支行',date_format('2016-2-23','%Y-%m-%d'));
INSERT INTO Accounts
VALUES('00000000000000000004',50000,'中国银行金寨路支行',date_format('2019-7-10','%Y-%m-%d'));
INSERT INTO Accounts
VALUES('00000000000000000005',200000,'中国银行金寨路支行',date_format('2022-1-3','%Y-%m-%d'));

# 储蓄账户 与 支票账户
INSERT INTO Storage_Account
VALUES('00000000000000000001','中国银行金寨路支行',0.03,'RMB');
INSERT INTO Check_Account
VALUES('00000000000000000002','中国银行金寨路支行',50000);
INSERT INTO Storage_Account
VALUES('00000000000000000003','中国银行八一大道支行',0.035,'RMB');
INSERT INTO Storage_Account
VALUES('00000000000000000004','中国银行金寨路支行',0.05,'USD');
INSERT INTO Check_Account
VALUES('00000000000000000005','中国银行金寨路支行',500000);

#贷款
Insert INto Loan
VALUES('00000000000020190203','中国银行金寨路支行',4000,2);
Insert INto Loan
VALUES('00000000000020220318','中国银行金寨路支行',6000,0);
Insert INto Loan
VALUES('00000000000020211231','中国银行金寨路支行',40000,1);

# 付款
Insert INto Pay
VALUES('00000000000020190203',1,'中国银行金寨路支行',1000,date_format('2019-2-5','%Y-%m-%d'));
Insert INto Pay
VALUES('00000000000020190203',2,'中国银行金寨路支行',3000,date_format('2019-2-10','%Y-%m-%d'));
Insert INto Pay
VALUES('00000000000020211231',1,'中国银行金寨路支行',10000,date_format('2022-1-3','%Y-%m-%d'));

# 拥有贷款
INSERT INTO  Own_Account
VALUES('360103100202122878','00000000000000000001',date_format('2022-4-10','%Y-%m-%d'));
INSERT INTO  Own_Account
VALUES('360103100202122878','00000000000000000002',date_format('2022-4-19','%Y-%m-%d'));
INSERT INTO  Own_Account
VALUES('360103100202122878','00000000000000000003',date_format('2022-4-1','%Y-%m-%d'));
INSERT INTO Own_Account
VALUES('360102987329381730','00000000000000000004',date_format('2022-5-1','%Y-%m-%d'));
INSERT INTO Own_Account
VALUES('360102987329381730','00000000000000000005',date_format('2022-4-20','%Y-%m-%d'));

# 拥有账户
INSERT INTO  Own_Loan
VALUES('360103100202122878','00000000000020190203');
INSERT INTO  Own_Loan
VALUES('360103100202122878','00000000000020220318');
INSERT INTO  Own_Loan
VALUES('360102987329381730','00000000000020211231');
