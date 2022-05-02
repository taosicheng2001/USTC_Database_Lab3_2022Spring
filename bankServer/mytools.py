from decimal import Decimal

def my_unwrap(table_dict):
    table_list = []
    
    # 列表名
    row_list = []
    for key in table_dict[0].keys():
        row_list.append(key) 
    table_list.append(row_list)

    #列表属性
    for row in table_dict:
        row_list = []
        for value in row.values():
            if isinstance(value,Decimal):
                row_list.append(value.to_eng_string())
            else:
                row_list.append(value)
        table_list.append(row_list)
    return table_list