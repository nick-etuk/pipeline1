from datetime import datetime

from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.registry.steps.scan_tree import scantree


def scan_script_libraries(last_scan_time_param: float) -> bool:
    lib_dir = f"{config['script_root']}/lib"

    last_scan_time = float(last_scan_time_param)
    included_extensions = ['.sh', '.ps1']
    for entry in scantree(lib_dir):
        if not any(entry.name.endswith(ext) for ext in included_extensions):
            continue
        update_time = entry.stat().st_mtime
        if update_time > last_scan_time:
            log.info('Script library file change detected')
            log.info(f"File: {entry.path}")
            log.info(f"Update time: {datetime.fromtimestamp(update_time).strftime('%Y-%m-%d %H:%M')}")
            log.info(f"Last scan time: {datetime.fromtimestamp(last_scan_time).strftime('%Y-%m-%d %H:%M')}")
            return True
    
    return False

        
