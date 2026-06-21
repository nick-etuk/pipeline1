import os

def scan_sub_directories(path):
    # Recursively yield DirEntry objects for given directory.
    for entry in os.scandir(path):
        if entry.is_dir(follow_symlinks=False):
            yield from scan_sub_directories(entry.path)  
        else:
            yield entry
    