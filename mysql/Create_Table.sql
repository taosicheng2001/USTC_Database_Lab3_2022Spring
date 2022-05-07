
# 状态表
Create Table State(
   state INT not null
);
Insert INTO State
VALUES(0);

# 客户
create TABLE Client(
   client_id            char(18) not null,
   client_name          varchar(10) not null,
   client_pn            DECIMAL(11,0) not null,
   client_addr          varchar(50) not null,
   connector_name       VarChar(10) not null,
   connector_pn         DECIMAL(11,0) not null,
   connector_email      varchar(30) not null,
   relationship         varchar(20) not null, 
   Constraint PK_CLT primary key(client_id)
);
drop TABLE client;

# 支行
create table SB(
   sb_name Varchar(20) not null,
   sb_city Varchar(20) not null,
   sb_asset double not null,
   CONSTRAINT PK_SB PRIMARY Key(sb_name)
);
drop table SB;

# 账户池
create Table Accounts(
    account_id varchar(20) not null,
    balance Decimal(20,6) not null,
    sb_name Varchar(20) not null,
    create_account_date  date not null,
    CONSTRAINT PK_ACCS PRIMARY key(account_id),
    CONSTRAINT FK_ACCS_SB FOREIGN key(sb_name) REFERENCES SB(sb_name)  
);
drop table accounts;

# 储蓄账户
create table Storage_Account
(
   account_id            char(20) not null,
   benefit_rate          double not null,
   money_type            varchar(10) not null,
   Constraint PK_STACC primary key(account_id),
   Constraint FK_STACC_ACC FOREIGN key(account_id) REFERENCES Accounts(account_id)
);
drop table storage_account;

# 支票账户
create table Check_Account
(
   account_id           char(20) not null,
   credit_line         Decimal(20,6) not null,
   Constraint PK_CKACC primary key(account_id),
   Constraint FK_CKACC_ACC FOREIGN key(account_id) REFERENCES Accounts(account_id)
);
drop table Check_Account;

# 拥有账户
create table Own_Account
(
   client_id            char(18) not null,
   account_id           char(20) not null,
   last_access_date     date not NULL,
   CONSTraint PK_OAC primary key(client_id,account_id),
   CONSTRAINT FK_OAC_CLT FOREIGN key(client_id) REFERENCES Client(client_id),
   CONSTRAINT FK_OAC_ACC FOREIGN KEY(account_id) REFERENCES Accounts(account_id)
);
drop table Own_Account;

# 贷款
create Table Loan(
   loan_id CHAR(20) not null,
   sb_name VARCHAR(20) not null,
   loan_sum Decimal(20,6) not null,
   loan_state int not null,
   CONSTRAINT PK_LN PRIMARY key(loan_id),
   CONSTRAINT FK_LN_SB FOREIGN Key(sb_name) REFERENCES SB(sb_name)
);
drop table loan;

# 付款
create table Pay(
   loan_id CHAR(20) not null,
   pay_order int not null,
   sb_name VARCHAR(20) not null,
   pay_sum Decimal(20,6) not null,
   pay_date date not null,
   Constraint PK_PY PRIMARY key(loan_id,pay_order),
   Constraint FK_PY_LOAN FOREIGN key(loan_id) REFERENCES Loan(loan_id),
   Constraint FK_PY_SB FOREIGN key(sb_name) REFERENCES SB(sb_name)
);
drop table Pay;

# 拥有贷款
create Table Own_Loan(
   client_id Char(18) not null,  
   loan_id  Char(20) not null,
   Constraint PK_OLN PRIMARY key(client_id,loan_id),
   Constraint FK_OLN_CLT FOREIGN key(client_id) REFERENCES Client(client_id),
   Constraint FK_OLN_LN FOREIGN key(loan_id) REFERENCES Loan(loan_id)
);
Drop table Own_Loan;

# 部门
create table Department(
   department_id Char(20) not null,
   sb_name VarChar(20) not null,
   department_name Varchar(20) not null,
   department_type int not null,
   Constraint PK_DPT PRIMARY key(department_id),
   Constraint FK_DPT_SB FOREIGN key(sb_name) REFERENCES SB(sb_name)
);
drop table department;

# 银行员工
create Table Worker(
   worker_id Char(18) not null,
   department_id char(5) not null,
   worker_name VARCHAR(10) not null,
   worker_pn DECIMAL(11,0) not null,
   worker_addr VARCHAR(50) not null,
   begin_work_date date not null,
   Constraint PK_WKR PRIMARY key(worker_id),
   Constraint FK_WKR_DPT FOREIGN key(department_id) REFERENCES Department(department_id) 
);
drop table Worker;

alter Table worker
   drop FOREIGN KEY FK_WKR_IDS;




drop table Own_Loan;

# 联系
create Table  Connect(
   client_id char(18) not null,
   worker_id char(18) not null,
   connect_type VarChar(15) not null,
   Constraint PK_CNT PRIMARY key(client_id,worker_id),
   Constraint FK_CNT_CLT FOREIGN key(client_id) REFERENCES Client(client_id),
   Constraint FK_CNT_WKR FOREIGN key(worker_id) REFERENCES Worker(worker_id)
);
drop table Connect;

# 管理
create Table Manager(
   worker_id Char(18) not null,
   department_id char(20) not null,
   Constraint PK_MNG PRIMARY key(worker_id,department_id),
   Constraint FK_MNG_WKR FOREIGN key(worker_id) REFERENCES Worker(worker_id),
   COnstraint FK_MNG_DPT FOREIGN key(department_id) REFERENCES Department(department_id)
);

drop table manager;

# 临时表，用于处理账户约束
Create Table cur_table(
   sb_name VarChar(20),
   account_type INT,
   cnt INT DEFAULT 0,
   CONSTRAINT PK PRIMARY KEY(sb_name,account_type)
);
DROP table cur_table;