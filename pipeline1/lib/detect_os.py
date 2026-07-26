import platform
# from pipeline1.lib.logging import log

def detect_wsl() -> bool:
    if platform.system().lower() != 'linux':
        return False
    try:
        with open('/proc/version', 'r') as f:
            version_info = f.read().lower()
            return 'microsoft' in version_info or 'wsl' in version_info
    except FileNotFoundError:
        return False

def detect_os() -> tuple[str, str]:
    os_name = platform.system().lower()
    vm = 'none'
    if 'linux' in os_name:
        os = 'ubuntu'
        # if detect_wsl():
        if 'microsoft' in platform.release().lower():
            vm = 'wsl'
    elif 'darwin' in os_name:
        os = 'macos'
    elif 'windows' in os_name:
        os = 'win'
    else:
        os = 'unknown'
    return os, vm