from datetime import datetime, timezone
from pathlib import Path

from pipeline1.lib.config import config
from pipeline1.lib.logging import log
from pipeline1.registry.detect_code_changes.scan_sub_directories import scan_sub_directories


def check_libraries(last_scan_time_param: float) -> bool:
    lib_dir = f"{config['script_root']}/lib"

    last_scan_time = float(last_scan_time_param)
    included_extensions = ['.sh', '.ps1']
    for entry in scan_sub_directories(Path(lib_dir)):
        if not any(entry.name.endswith(ext) for ext in included_extensions):
            continue
        update_time = entry.stat().st_mtime
        if update_time > last_scan_time:
            log.info(f"Library change detected: {entry.name}")
            log.info(f"Updated at {datetime.fromtimestamp(update_time, tz=timezone.utc).strftime('%Y-%m-%d %H:%M:%S')}")
            return True
    
    return False

        
