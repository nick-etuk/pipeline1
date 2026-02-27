import os
from pipeline1.lib.config import config

def get_new_tab_file() -> str:
    new_tab_queue_dir = f"{config['working_dir']}/new_tab_queue"
    if not os.path.exists(new_tab_queue_dir):
        os.makedirs(new_tab_queue_dir)
        return ''
    
    list_of_files = [f for f in os.listdir(new_tab_queue_dir) if f.endswith('.txt')]
    if len(list_of_files) == 0:
        return ''
    
    oldest_file = sorted(list_of_files, key=lambda x: os.path.getctime(os.path.join(new_tab_queue_dir, x)))[0]
    return os.path.join(new_tab_queue_dir, oldest_file)

