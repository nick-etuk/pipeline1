from datetime import datetime

from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.registry.steps.scan_tree import scantree


def scan_core(last_scan_time_param: float) -> bool:
    core_dir = config['p1_root']

    last_scan_time = float(last_scan_time_param)
    for entry in scantree(core_dir):
        if '__test' in str(entry.path):
            continue
        if not entry.name.endswith('.py'):
            continue
        update_time = entry.stat().st_mtime
        if update_time > last_scan_time:
            log.info('Core file change detected')
            log.info(f"File: {entry.path}")
            log.info(f"Update time: {datetime.fromtimestamp(update_time).strftime('%Y-%m-%d %H:%M')}")
            log.info(f"Last scan time: {datetime.fromtimestamp(last_scan_time).strftime('%Y-%m-%d %H:%M')}")
            return True
    
    return False

        
