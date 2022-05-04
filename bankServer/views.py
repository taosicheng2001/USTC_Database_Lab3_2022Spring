from decimal import Decimal
from multiprocessing import Manager
from urllib.request import HTTPRedirectHandler
from colorama import Cursor
from django.shortcuts import render
from django.template import loader
from django.http import Http404, HttpResponse, HttpResponseRedirect
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

def function_page(request):
    return render(request,'bankServer/function_page.html')

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

def make_loan_submit(request):
    try:
        request.POST.get("comfirm_make_loan")
        client_id = request.POST.get("make_loan_client_id")
        sb_name = request.POST.get("make_loan_sb_name")
        loan_sum = request.POST.get("make_loan_loan_sum")
    except KeyError:
        raise Http404("Error!")

    print(client_id,sb_name,loan_sum)

    try:
        with connection.cursor() as cursor:
            cursor.callproc('Make_Loan',[client_id,sb_name,loan_sum])
            cursor.execute('Select * From State')
            row = dictfetchall(cursor)
    except NameError:
        raise Http404("错误!")

    content={
        'state_value':row[0]
    }

    print(content['state_value'])

    return render(request,'bankServer/make_loan_submit.html',content)

# 字典取
def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns,row))
        for row in cursor.fetchall()
    ]