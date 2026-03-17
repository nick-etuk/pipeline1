import os
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

# from icecream import ic

def open_new_tab():
    my_env = os.environ.copy()

    if config['my_os'] == 'win':
        subprocess.run(['wt.exe', '-w', '0','new-tab', 'pwsh', '-NoExit'])
        return
    
    if config['vm'] == 'wsl':
        log.debug("WSL detected, opening new Windows Terminal tab. Terminal_login.sh will then run the next sheduled step.")
        subprocess.run(['wt.exe', '-w', '0', 'new-tab', '--colorScheme', 'Campbell Powershell', '--title', 'Pipeline1', '-p', 'Ubuntu'], env=my_env)
        return
    
    if config['my_os'] in ['ubuntu', 'macos']:
        subprocess.run(['ttab'], shell=True)