import os  
import shutil
from openpyxl import Workbook  

def delete_files_in_folders(base_dir): 
    """删除目标文件中所有文件下的文件

    Args:
        base_dir (_type_): 文件名，需要和该程序位于同目录下
    """     
    # 询问用户是否确定要删除所有文件  
    confirm = input(f"Are you sure you want to delete all files in {base_dir}? (yes/no) ")  
    if confirm.lower() != 'yes':  
        print("Operation cancelled by user.")  
        return  
  
    # 遍历base_dir下的所有子文件夹和文件  
    for root, dirs, files in os.walk(base_dir):  
        # 遍历每个子文件夹中的文件  
        for file in files:  
            file_path = os.path.join(root, file)  
            # 删除文件  
            try:  
                os.remove(file_path)  
                print(f"Deleted {file_path}")  
            except OSError as e:  
                print(f"Error: {file_path} : {e.strerror}")  
  
# 使用你的大文件夹路径替换下面的'data1'  
delete_files_in_folders('data1')
 

def create_excel_files(base_dir,filenames):
    """批量为文件夹下的文件添加excel表

    Args:
        base_dir (_type_): 文件名，需要和该程序位于同目录下
        filenames (_type_): 将要建立的excel表名
    """  
    # 便利base_dir下的所有子文件
    for subdir,_,_ in os.walk(base_dir):
        # 在每个子文件中创建excel文件
        for filename in filenames:
            file_name = os.path.join(subdir,filename)
            wb = Workbook()
            wb.save(filename=file_name)
            print(f"Creatd{file_name}")

# 输入要创建的excel文件名称
excel_filenames = [
"流量日表.xlsx",
"输沙率日表.xlsx",
"含沙量日表.xlsx",
"洪水要素.xlsx",
"降水量摘录表.xlsx",
"降水量日表.xlsx",
"实测流量.xlsx",
"水位日表.xlsx"
#可以创建跟多文件名
]

create_excel_files('data1',excel_filenames)