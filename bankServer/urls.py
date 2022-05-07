from django.urls import path

from . import views

urlpatterns = [
    path('',views.index,name='index'),
    path('<str:table_name>/detail/',views.detail,name='detail'),
    path('<str:sql_string>/sql_search/',views.sql_search,name='sql_search'),
    path('submit/',views.submit,name='submit'),
    path('loan_management/loan_submit/',views.loan_submit,name="loan_submit"),
    path('loan_management/',views.loan_management,name='loan_management'),
    path('account_management/account_submit/',views.account_submit,name="account_submit"),
    path('account_management/',views.account_management,name='account_management'),
    path('client_management/client_submit/',views.client_submit,name="client_submit"),
    path('client_management/',views.client_management,name='client_management'),
    path('statistic_management/statistic_submit/',views.statistic_submit,name="statistic_submit"),
    path('statistic_management/',views.statistic_management,name='statistic_management'),

]