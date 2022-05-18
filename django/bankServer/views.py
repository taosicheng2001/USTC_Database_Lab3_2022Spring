from cgi import parse_multipart
from decimal import Decimal
from multiprocessing import Manager
from traceback import print_tb
from urllib.request import HTTPRedirectHandler
from colorama import Cursor
from django.forms import DecimalField
from django.shortcuts import render
from django.template import loader
from django.http import Http404, HttpResponse, HttpResponseRedirect
from pymysql import NULL
from datetime import date
from bankServer import models
from .models import Client
from .mytools import my_unwrap,nullcheck
from django.db import connection
from django.urls import reverse
from django.contrib.auth.decorators import permission_required

# Create your views here.

def index(request):
    data_number_list = []
    data_number_list.append(models.Client.objects.count) # Client
    data_number_list.append(models.Accounts.objects.count) # Account
    data_number_list.append(models.CheckAccount.objects.count) # Check_Account
    data_number_list.append(models.StorageAccount.objects.count) # Storage_Account
    data_number_list.append(models.Loan.objects.count) # Loan
    data_number_list.append(models.OwnAccount.objects.count) # Own_Account
    data_number_list.append(models.OwnLoan.objects.count) # Own_Loan
    data_number_list.append(models.Pay.objects.count) # Pay
    data_number_list.append(models.Sb.objects.count) # SB
    data_number_list.append(models.Worker.objects.count) # Worker
    data_number_list.append(models.Connect.objects.count) # Connect
    context = {
        'data_number_list':data_number_list,
    }
    return render(request,'bankServer/index.html',context)

def loan_management(request):
    return render(request,'bankServer/loan_management.html')

def account_management(request):
    return render(request,'bankServer/account_management.html')

def client_management(request):
    return render(request,'bankServer/client_management.html')

def statistic_management(request):
    return render(request,'bankServer/statistic_management.html')

def detail(request,table_name):
    try:
        table = getattr(models,table_name)
    except AttributeError:
        raise Http404("表格不存在")
    table_list = my_unwrap(table.objects.values())
    content = {
        'table_content':table_list
    }
    return render(request,'bankServer/detail.html',content)    

# SQL 语句查询
def sql_search(request,sql_string):
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql_string)
            row = dictfetchall(cursor)
    except NameError:
        raise Http404("表格不存在")

    result_list = my_unwrap(row)
    print(result_list)
    content = {
        'result_list':result_list
    }
    return render(request,'bankServer/sql_search.html',content)

def submit(request):
    sql_string = request.POST.get("sql_sentence")
    if sql_string.split()[0].lower() != 'select' :
        raise Http404("非法操作！")
    return HttpResponseRedirect(reverse('sql_search',args=(sql_string,)))

def loan_submit(request):

    # Loan Management
    try:
        params = []

        # try search_loan
        search_loan = request.POST.get("search_loan")
        if(search_loan == "查询"):
            loan_id = request.POST.get("search_loan_loan_id")
            search_type = request.POST.get("search_loan_information")
            if search_type is None or search_type == "贷款信息":
                sql_string = "Select * from  Loan Where Loan.loan_id="+loan_id
            else:
                sql_string = "Select * from  Loan,Pay Where Loan.loan_id = Pay.loan_id and Loan.loan_id="+loan_id
            return HttpResponseRedirect(reverse('sql_search',args=(sql_string,)))


        # try make_loan
        make_loan = request.POST.get("make_loan")
        if(make_loan == "创建贷款"):
            client_id = request.POST.get("make_loan_client_id")
            sb_name = request.POST.get("make_loan_sb_name")
            loan_sum = request.POST.get("make_loan_loan_sum")
            params.append(client_id)
            params.append(sb_name)
            params.append(loan_sum)
            action = "Make_Loan"
        else:
            print("Not Make_Loan")

        # try append_ownloan
        append_ownloan = request.POST.get("append_ownloan")
        if(append_ownloan == "添加贷款拥有者"):
            client_id = request.POST.get("append_ownloan_client_id")
            loan_id = request.POST.get("append_ownloan_loan_id")
            params.append(client_id)
            params.append(loan_id)
            action = "Append_Ownloan"
            print(params)
        else:
            print("Not Append_Ownloan")

        # try del_loan
        del_loan = request.POST.get("del_loan")
        if(del_loan == "删除贷款"):
            loan_id = request.POST.get("del_loan_id")
            params.append(loan_id)
            action = "Del_Loan"
        else:
            print("Not Del_Loan")

        # try pay
        pay_loan = request.POST.get("pay_loan")
        if(pay_loan == "支付贷款"):
            sb_name = request.POST.get("pay_sb_name")
            loan_id = request.POST.get("pay_loan_id")
            pay_sum = request.POST.get("pay_pay_sum")
            pay_date = request.POST.get("pay_pay_date")
            params.append(sb_name)
            params.append(loan_id)
            params.append(pay_sum)
            params.append(pay_date)
            action = "Make_Payment"
        else:
            print("Not Make_Payment")

        try:
            with connection.cursor() as cursor:
                cursor.callproc(action,params)
                cursor.execute('Select * From State')
                row = dictfetchall(cursor)
        except NameError:
            raise Http404("错误!")

        content={
            'action':action,
            'state_value':row[0]
        }

        return render(request,'bankServer/loan_submit.html',content)
        

    except KeyError:
        raise Http404("Error!")

def account_submit(request):

    # Account Management
    try:
        params = []

        # try search account
        search_account = request.POST.get("search_account")
        if(search_account == "查询"):
            account_id = request.POST.get("search_account_account_id")
            search_type = request.POST.get("search_account_information")
            if search_type is None or search_type == "储蓄账户":
                sql_string = "Select * from  Own_Account,Accounts,Storage_Account Where Own_Account.account_id = Accounts.account_id and Accounts.account_id = Storage_Account.account_id and Accounts.account_id="+account_id
            else:
                sql_string = "Select * from  Own_Account,Accounts,Check_Account Where Own_Account.account_id = Accounts.account_id and Accounts.account_id = Check_Account.account_id and Accounts.account_id="+account_id
            return HttpResponseRedirect(reverse('sql_search',args=(sql_string,)))

        # try create_storage_account
        create_storage_account = request.POST.get("create_storage_account")
        if(create_storage_account == "创建储蓄账户"):
            client_id = request.POST.get("create_storage_account_client_id")
            sb_name = request.POST.get("create_storage_account_sb_name")
            balance = request.POST.get("create_storage_account_balance")
            benefit_rate = request.POST.get("create_storage_account_benefit_rate")
            money_type = request.POST.get("create_storage_account_money_type")
            create_date = request.POST.get("create_storage_account_create_date")
            params.append(client_id)
            params.append(sb_name)
            params.append(balance)
            params.append(benefit_rate)
            params.append(money_type)
            params.append(create_date)
            action = "Create_Storage_Account"
        else:
            print("Not Create_Storage_Account")

        # try create_check_account
        create_check_account = request.POST.get("create_check_account")
        if(create_check_account == "创建支票账户"):
            client_id = request.POST.get("create_check_account_client_id")
            sb_name = request.POST.get("create_check_account_sb_name")
            balance = request.POST.get("create_check_account_balance")
            credit_line = request.POST.get("create_storage_account_credit_line")
            create_date = request.POST.get("create_storage_account_create_date")
            params.append(client_id)
            params.append(sb_name)
            params.append(balance)
            params.append(credit_line)
            params.append(create_date)
            action = "Create_Check_Account"
        else:
            print("Not Create_Check_Account")

        # try append_ownaccount
        append_ownaccount = request.POST.get("append_ownaccount")
        if(append_ownaccount == "添加账户拥有者"):
            client_id = request.POST.get("append_ownaccount_client_id")
            account_id = request.POST.get("append_ownaccount_account_id")
            append_date = request.POST.get("append_ownaccount_append_date")
            params.append(client_id)
            params.append(account_id)
            params.append(append_date)
            action = "Append_OwnAccount"
        else:
            print("Not Append_OwnAccount")

        # try del_account
        del_account = request.POST.get("del_account")
        if(del_account == "删除账户"):
            account_id = request.POST.get("del_account_account_id")
            params.append(account_id)
            action = "Del_Account"
        else:
            print("Not Del_Account")

        # try modify_storage_account
        modify_storage_account = request.POST.get("modify_storage_account")
        if(modify_storage_account == "修改储蓄账户"):
            client_id = request.POST.get("modify_storage_account_client_id")
            account_id = request.POST.get("modify_storage_account_account_id")
            balance = request.POST.get("modify_storage_account_balance")
            benefit_rate = request.POST.get("modify_storage_account_benefit_rate")
            money_type = request.POST.get("modify_storage_account_money_type")
            params.append(nullcheck(client_id))
            params.append(nullcheck(account_id))
            params.append(nullcheck(balance))
            params.append(nullcheck(benefit_rate))
            params.append(nullcheck(money_type))
            action = "Modify_Storage_Account"
        else:
            print("Not Modify_Storage_Account")

        # try modify_check_account
        modify_check_account = request.POST.get("modify_check_account")
        if(modify_check_account == "修改支票账户"):
            client_id = request.POST.get("modify_check_account_client_id")
            account_id = request.POST.get("modify_check_account_account_id")
            balance = request.POST.get("modify_check_account_balance")
            credit_line = request.POST.get("modify_check_account_credit_line")
            params.append(nullcheck(client_id))
            params.append(nullcheck(account_id))
            params.append(nullcheck(balance))
            params.append(nullcheck(credit_line))
            action = "Modify_Check_Account"
        else:
            print("Not Modify_Check_Account")

        # try migration_account
        migration_account = request.POST.get("migration_account")
        if(migration_account == "迁移账户"):
            account_id = request.POST.get("migration_account_account_id")
            sb_name = request.POST.get("migration_account_sb_name")
            params.append(account_id)
            params.append(sb_name)
            action = "Migration_Account"
        else:
            print("NOT Migration_Account")

        try:
            with connection.cursor() as cursor:
                print(action)
                print(params)
                cursor.callproc(action,params)
                cursor.execute('Select * From State')
                row = dictfetchall(cursor)
        except NameError:
            raise Http404("错误!")

        content={
            'action':action,
            'state_value':row[0]
        }

        return render(request,'bankServer/account_submit.html',content)
        

    except KeyError:
        raise Http404("Error!")

def client_submit(request):

    # Client Management
    try:
        params = []

        # try create_client
        create_client = request.POST.get("create_client")
        if(create_client == "创建客户"):
            client_id = request.POST.get("create_client_client_id")
            client_name = request.POST.get("create_client_client_name")
            client_pn = request.POST.get("create_client_client_pn")
            client_addr = request.POST.get("create_client_client_addr")
            connector_name = request.POST.get("create_client_connector_name")
            connector_pn = request.POST.get("create_client_connector_pn")
            connector_email = request.POST.get("create_client_connector_email")
            relationship = request.POST.get("create_client_relationship")
            params.append(client_id)
            params.append(client_name)
            params.append(client_pn)
            params.append(client_addr)
            params.append(connector_name)
            params.append(connector_pn)
            params.append(connector_email)
            params.append(relationship)
            action = "Create_Client"
        else:
            print("Not Create_Client")

        # try del_client
        del_client = request.POST.get("del_client")
        if(del_client == "删除客户"):
            client_id = request.POST.get("del_client_client_id")
            print(client_id)
            params.append(client_id)
            action = "Del_Client"
        else:
            print("Not Del_Client")

        # try modify client
        modify_client = request.POST.get("modify_client")
        if(modify_client == "修改客户信息"):
            client_id = request.POST.get("modify_client_client_id")
            client_name = request.POST.get("modify_client_client_name")
            client_pn = request.POST.get("modify_client_client_pn")
            client_addr = request.POST.get("modify_client_client_addr")
            connector_name = request.POST.get("modify_client_connector_name")
            connector_pn = request.POST.get("modify_client_connector_pn")
            connector_email = request.POST.get("modify_client_connector_email")
            relationship = request.POST.get("modify_client_relationship")
            params.append(nullcheck(client_id))
            params.append(nullcheck(client_name))
            params.append(nullcheck(client_pn))
            params.append(nullcheck(client_addr))
            params.append(nullcheck(connector_name))
            params.append(nullcheck(connector_pn))
            params.append(nullcheck(connector_email))
            params.append(nullcheck(relationship))
            action = "Modify_Client"
        else:
            print("Not Modify_Client")

        # try modify_connection
        modify_connection = request.POST.get("modify_connection")
        if (modify_connection == "创建或修改联系"):
            client_id = request.POST.get("modify_connection_client_id")
            worker_id = request.POST.get("modify_connection_worker_id")
            connect_type = request.POST.get("modify_connection_connect_type")
            params.append(client_id)
            params.append(worker_id)
            if connect_type == "贷款负责人":
                params.append("贷款负责人")
            else:
                params.append("银行帐户负责人")

            action = "Modify_Connection"
        else:
            print("Not Modify_Connection")

        # try del_connection
        del_connection = request.POST.get("del_connection")
        if (del_connection == "删除联系"):
            client_id = request.POST.get("del_connection_client_id")
            worker_id = request.POST.get("del_connection_worker_id")
            params.append(client_id)
            params.append(worker_id)
            action = "Del_Connection"
        else:
            print("Not Del_Connection")

        # try search client
        search_client = request.POST.get("search_client")
        if(search_client == "查询"):
            client_id = request.POST.get("search_client_client_id")
            search_type = request.POST.get("search_client_information")
            if search_type is None or search_type == "客户个人信息":
                sql_string = "Select * from Client Where Client.client_id=" + client_id
            else:
                if search_type == "联系关系信息":
                    sql_string = "Select connect_type,department_id,worker_name,worker_pn,worker_addr from Connect,Worker Where Connect.worker_id = Worker.worker_id and Connect.client_id="+client_id
                if search_type == "客户账户信息":
                    sql_string = "Select * from Accounts,Own_Account Where Own_Account.account_id = Accounts.account_id and Own_Account.client_id="+ client_id
                if search_type == "客户贷款信息":
                    sql_string = "Select Loan.loan_id,sb_name,loan_sum,loan_state from Loan,Own_Loan Where Own_Loan.loan_id = Loan.loan_id and Own_Loan.client_id = " + client_id

            return HttpResponseRedirect(reverse('sql_search',args=(sql_string,)))


        try:
            with connection.cursor() as cursor:
                cursor.callproc(action,params)
                cursor.execute('Select * From State')
                row = dictfetchall(cursor)
        except NameError:
            raise Http404("错误!")

        content={
            'action':action,
            'state_value':row[0]
        }

        return render(request,'bankServer/client_submit.html',content)
        

    except KeyError:
        raise Http404("Error!")

def statistic_submit(request):

    # Statistic Management
    try:
        params = []

        # try statistic storage all year
        statistic_storage_all_year = request.POST.get("statistic_storage_all_year")
        if(statistic_storage_all_year == "全局储蓄业务统计"):
            action = "Statistic_Storage_All_Year"
        else:
            print("Not Statistic_Storage_All_Year")

        # try statistic loan all year
        statistic_loan_all_year = request.POST.get("statistic_loan_all_year")
        if(statistic_loan_all_year == "全局贷款业务统计"):
            action = "Statistic_Loan_All_Year"
        else:
            print("Not Statistic_Loan_All_Year")

        # try statistic_storage
        statistic_storage = request.POST.get("statistic_storage")
        if(statistic_storage == "详细储蓄业务统计"):
            whether_sb = request.POST.get("statistic_storage_sb")
            sb_name = request.POST.get("statistic_storage_sb_name")
            cut_type = request.POST.get("statistic_storage_cut_type")
            year = request.POST.get("statistic_storage_year")
            month = request.POST.get("statistic_storage_month")
            quarter = request.POST.get("statistic_storage_quarter")
            
            # time type
            if len(month) == 0 and len(quarter) == 0:
                params.append(0)
            else:
                if len(month) == 0:
                    params.append(2)
                else:
                    params.append(1)
            
            # cut type
            if cut_type == "Year":
                params.append(0)
            else:
                if cut_type == "Month":
                    params.append(1)
                else:
                    params.append(2)

            # time
            year = int(year)
            if len(month) == 0:
                if len(quarter) == 0:
                    d = date(year,1,1)
                else:
                    if quarter == "1":
                        d = date(year,1,1)
                    if quarter == "2":
                        d = date(year,4,1)
                    if quarter == "3":
                        d = date(year,7,1)
                    if quarter == "4":
                        d = date(year,10,1)                
            else:
                d = date(year,int(month),1)
            params.append(d)

            if whether_sb == "Yes":
                params.append(sb_name)
            else:
                params.append(None)     
            action = "Statistic_Storage"
        else:
            print("Not Statistic_Storage")

        # try statistic_loan
        statistic_loan = request.POST.get("statistic_loan")
        if(statistic_loan == "详细贷款业务统计"):
            whether_sb = request.POST.get("statistic_loan_sb")
            sb_name = request.POST.get("statistic_loan_sb_name")
            cut_type = request.POST.get("statistic_loan_cut_type")
            year = request.POST.get("statistic_loan_year")
            month = request.POST.get("statistic_loan_month")
            quarter = request.POST.get("statistic_loan_quarter")
            
            # time type
            if len(month) == 0 and len(quarter) == 0:
                params.append(0)
            else:
                if len(month) == 0:
                    params.append(2)
                else:
                    params.append(1)
            
            # cut type
            if cut_type == "Year":
                params.append(0)
            else:
                if cut_type == "Month":
                    params.append(1)
                else:
                    params.append(2)

            # time
            year = int(year)
            if len(month) == 0:
                if len(quarter) == 0:
                    d = date(year,1,1)
                else:
                    if quarter == "1":
                        d = date(year,1,1)
                    if quarter == "2":
                        d = date(year,4,1)
                    if quarter == "3":
                        d = date(year,7,1)
                    if quarter == "4":
                        d = date(year,10,1)                
            else:
                d = date(year,int(month),1)
            params.append(d)

            if whether_sb == "Yes":
                params.append(sb_name)
            else:
                params.append(None)     
            action = "Statistic_Loan"
        else:
            print("Not Statistic_Loan")

        print(params)

        try:
            with connection.cursor() as cursor:
                cursor.callproc(action,params)
                table_content = dictfetchall(cursor)
                cursor.execute('Select * From State')
                row = dictfetchall(cursor)
        except NameError:
            raise Http404("错误!")


        content={
            'action':action,
            'state_value':row[0],
            'table_content': my_unwrap(table_content)
        }

        print(content)

        return render(request,'bankServer/statistic_submit.html',content)
        

    except KeyError:
        raise Http404("Error!")


# 字典取
def dictfetchall(cursor):
    if cursor.description is None:
        return None
    
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns,row))
        for row in cursor.fetchall()
    ]