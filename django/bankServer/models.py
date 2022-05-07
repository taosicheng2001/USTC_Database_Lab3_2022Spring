# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class Accounts(models.Model):
    account_id = models.CharField(primary_key=True, max_length=20)
    balance = models.DecimalField(max_digits=20, decimal_places=6)
    sb_name = models.ForeignKey('Sb', models.DO_NOTHING, db_column='sb_name')
    create_account_date = models.DateField()

    class Meta:
        managed = False
        db_table = 'Accounts'


class CheckAccount(models.Model):
    account = models.OneToOneField(Accounts, models.DO_NOTHING, primary_key=True)
    credit_line = models.DecimalField(max_digits=20, decimal_places=6)

    class Meta:
        managed = False
        db_table = 'Check_Account'


class Client(models.Model):
    client_id = models.CharField(primary_key=True, max_length=18)
    client_name = models.CharField(max_length=10)
    client_pn = models.DecimalField(max_digits=11, decimal_places=0)
    client_addr = models.CharField(max_length=50)
    connector_name = models.CharField(max_length=10)
    connector_pn = models.DecimalField(max_digits=11, decimal_places=0)
    connector_email = models.CharField(max_length=30)
    relationship = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'Client'


class Connect(models.Model):
    client = models.OneToOneField(Client, models.DO_NOTHING, primary_key=True)
    worker = models.ForeignKey('Worker', models.DO_NOTHING)
    connect_type = models.CharField(max_length=15)

    class Meta:
        managed = False
        db_table = 'Connect'
        unique_together = (('client', 'worker'),)


class Department(models.Model):
    department_id = models.CharField(primary_key=True, max_length=5)
    sb_name = models.ForeignKey('Sb', models.DO_NOTHING, db_column='sb_name')
    department_name = models.CharField(max_length=20)
    department_type = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'Department'


class Loan(models.Model):
    loan_id = models.CharField(primary_key=True, max_length=20)
    sb_name = models.ForeignKey('Sb', models.DO_NOTHING, db_column='sb_name')
    loan_sum = models.FloatField()
    loan_state = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'Loan'


class Manager(models.Model):
    worker = models.OneToOneField('Worker', models.DO_NOTHING, primary_key=True)
    department = models.ForeignKey(Department, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Manager'
        unique_together = (('worker', 'department'),)


class OwnAccount(models.Model):
    client = models.OneToOneField(Client, models.DO_NOTHING, primary_key=True)
    account = models.ForeignKey(Accounts, models.DO_NOTHING)
    last_access_date = models.DateField()

    class Meta:
        managed = False
        db_table = 'Own_Account'
        unique_together = (('client', 'account'),)


class OwnLoan(models.Model):
    client = models.OneToOneField(Client, models.DO_NOTHING, primary_key=True)
    loan = models.ForeignKey(Loan, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'Own_Loan'
        unique_together = (('client', 'loan'),)


class Pay(models.Model):
    loan = models.OneToOneField(Loan, models.DO_NOTHING, primary_key=True)
    pay_order = models.IntegerField()
    sb_name = models.ForeignKey('Sb', models.DO_NOTHING, db_column='sb_name')
    pay_sum = models.FloatField()
    pay_date = models.DateField()

    class Meta:
        managed = False
        db_table = 'Pay'
        unique_together = (('loan', 'pay_order'),)


class Sb(models.Model):
    sb_name = models.CharField(primary_key=True, max_length=20)
    sb_city = models.CharField(max_length=20)
    sb_asset = models.FloatField()

    class Meta:
        managed = False
        db_table = 'SB'


class State(models.Model):
    state = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'State'


class StorageAccount(models.Model):
    account = models.OneToOneField(Accounts, models.DO_NOTHING, primary_key=True)
    benefit_rate = models.FloatField()
    money_type = models.CharField(max_length=10)

    class Meta:
        managed = False
        db_table = 'Storage_Account'


class Worker(models.Model):
    worker_id = models.CharField(primary_key=True, max_length=18)
    department = models.ForeignKey(Department, models.DO_NOTHING)
    worker_name = models.CharField(max_length=10)
    worker_pn = models.DecimalField(max_digits=11, decimal_places=0)
    worker_addr = models.CharField(max_length=50)
    begin_work_date = models.DateField()

    class Meta:
        managed = False
        db_table = 'Worker'


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.IntegerField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.IntegerField()
    is_active = models.IntegerField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.PositiveSmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    id = models.BigAutoField(primary_key=True)
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'
