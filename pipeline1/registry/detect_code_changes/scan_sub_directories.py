import os
from pathlib import Path
from collections.abc import Iterator

def scan_sub_directories(path: Path) -> Iterator[Path]:
    # Recursively yield DirEntry objects for given directory.
    for entry in os.scandir(path):
        if entry.is_dir(follow_symlinks=False):
            # yield from scan_sub_directories(entry.path)  
            yield from scan_sub_directories(Path(entry.path))
        else:
            yield Path(entry.path)
    