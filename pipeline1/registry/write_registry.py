import os
from pathlib import Path
import csv
from typing import Any
from pipeline1.lib.config import config
from pipeline1.lib.logging import log

def write_registry(registry: list[dict[str, Any]], type: str) -> None:
    log.info(f"Saving {type} registry")
    registry_file = os.path.join(config['working_dir'], f"{type}_registry.csv")

    if Path(registry_file).exists():
        os.remove(registry_file)


    with open(registry_file, 'w', newline='') as csvfile:
        fieldnames = registry[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(registry)

