from contextlib import nullcontext
from decimal import Decimal
from multiprocessing import Manager
from urllib.request import HTTPRedirectHandler
from colorama import Cursor
from django.shortcuts import render
from django.template import loader
from django.http import Http404, HttpResponse, HttpResponseRedirect
from pymysql import NULL
from bankServer import models
from .models import Client
from .mytools import my_unwrap
from django.db import connection
from django.urls import reverse

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
            params.append(client_id)
            params.append(account_id)
            params.append(balance)
            params.append(benefit_rate)
            params.append(money_type)
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
            params.append(client_id)
            params.append(account_id)
            params.append(balance)
            params.append(credit_line)
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
            params.append(client_id)
            params.append(client_name)
            params.append(client_pn)
            params.append(client_addr)
            params.append(connector_name)
            params.append(connector_pn)
            params.append(connector_email)
            params.append(relationship)
            action = "Modify_Client"
        else:
            print("Not Modify_Client")

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


# 字典取
def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns,row))
        for row in cursor.fetchall()
    ]