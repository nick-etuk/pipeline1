from datetime import datetime, timezone

from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.registry.detect_code_changes.scan_sub_directories import scan_sub_directories


def check_core(last_scan_time_param: float) -> bool:
    core_dir = config['p1_root']

    last_scan_time = float(last_scan_time_param)
    for entry in scan_sub_directories(core_dir):
        if '__test' in str(entry.parent):
            continue
        if not entry.name.endswith('.py'):
            continue
        update_time = entry.stat().st_mtime
        if update_time > last_scan_time:
            log.info(f"Core file changed: {entry.name}")
            log.info(f"Updated at {datetime.fromtimestamp(update_time, tz=timezone.utc).strftime('%Y-%m-%d %H:%M')}")
            return True
    
    return False

        
