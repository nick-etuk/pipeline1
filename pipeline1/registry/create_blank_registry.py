import os
from pipeline1.lib.constants import FILE_HEADERS
from pipeline1.lib.config import config
from pipeline1.lib.logging import log
import csv

def create_blank_registry(registry_type: str) -> None:
    if registry_type not in FILE_HEADERS:
        raise ValueError(f"Unknown registry type: {registry_type}")
    
    headers = FILE_HEADERS[registry_type]
    log.info(f"Creating new {registry_type} registry")
    registry_file = os.path.join(config['working_dir'], f"{registry_type}_registry.csv")

    with open(registry_file, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()