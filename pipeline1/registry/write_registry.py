import os
import tempfile
import csv
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

def write_registry(registry: list[dict[str, Any]], registry_type: str) -> None:
    log.info(f"Saving {registry_type} registry")
    registry_file = os.path.join(config['working_dir'], f"{registry_type}_registry.csv")

    # Write to a temp file first, then atomically replace to avoid a window
    # where the file is missing (which causes other code to blank the registry).
    dir_name = os.path.dirname(registry_file)
    fd, tmp_path = tempfile.mkstemp(suffix='.csv', dir=dir_name)
    try:
        with os.fdopen(fd, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = registry[0].keys()
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(registry)
        os.replace(tmp_path, registry_file)
    except BaseException:
        if os.path.exists(tmp_path):
            os.remove(tmp_path)
        raise

