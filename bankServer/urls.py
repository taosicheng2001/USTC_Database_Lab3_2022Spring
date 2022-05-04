from django.urls import path

from . import views

urlpatterns = [
    path('',views.index,name='index'),
    path('<str:table_name>/detail/',views.detail,name='detail'),
    path('<str:sql_string>/sql_search/',views.sql_search,name='sql_search'),
    path('submit/',views.submit,name='submit'),
    path('loan_management/loan_submit/',views.loan_submit,name="loan_submit"),
    path('loan_management/',views.loan_management,name='loan_management'),
]