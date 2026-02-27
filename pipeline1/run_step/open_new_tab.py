import os
import subprocess
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

# from icecream import ic

def open_new_tab():
    my_env = os.environ.copy()

    if config['my_os'] == 'win':
        # startup_script = os.path.join(config['p1_root'], 'p1.ps1')
        # subprocess.run(['wt', 'new-tab', 'pwsh', '-NoExit', '-File', startup_script])
        subprocess.run(['wt.exe', '-w', '0','new-tab', 'pwsh', '-NoExit'])
        return
    
    # startup_script = os.path.join(config['p1_root'], 'p1.sh')
    if config['vm'] == 'wsl':
        log.debug("WSL detected, opening new Windows Terminal tab with script")
        subprocess.run(['wt.exe', '-w', '0', 'new-tab', '--colorScheme', 'Campbell Powershell', '--title', 'Pipeline1', '-p', 'Ubuntu'], env=my_env)
        return
    
    if config['my_os'] in ['ubuntu', 'macos']:
        subprocess.run(['ttab'], shell=True)