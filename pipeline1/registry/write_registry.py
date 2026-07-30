import os
import tempfile
import csv
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

def write_registry(registry: list[dict[str, Any]], registry_type: str) -> None:
    log.info(f"Saving {registry_type} registry")
    # warn if registry is empty, but still write the file to avoid a missing file error
    if not registry or len(registry) == 0:
        # todo: remove prompt when blank project registry issue is solved.
        # log.warn(f"Warning: {registry_type} registry is empty. Writing empty registry file.")
        response = input(f"Warning: {registry_type} registry is empty. Write empty registry file? (y/n): ")
        if response.lower() != 'y':
            return

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

