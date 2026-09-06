import os
import subprocess
from pathlib import Path

from pipeline1.lib.config import config
from pipeline1.lib.context import get_context, set_context
from pipeline1.lib.logging import log
from pipeline1.registry.detect_code_changes.scan_sub_directories import scan_sub_directories


def check_directory(filename: str, path: str, expected_directory: str) -> str | None:
    if path == expected_directory:
        log.debug(f"{filename} in {expected_directory} found at {path}")
        return path
    log.debug(f"{filename} found, but not in expected directory {expected_directory}. Path found is {path}")
    return None


def get_command_path(filename: str) -> str | None:
    result = None
    command = f"Get-Command {filename} -errorAction SilentlyContinue | Select-Object -ExpandProperty Path"
    if config['my_os'] == 'win':
        command_array = ['pwsh', '-ExecutionPolicy', 'Bypass', '-Command', command]
        process = subprocess.run( command_array, capture_output=True, text=True, check=False)
    else:
        command_array = ['bash', '-c', command]
        process = subprocess.run(command_array, capture_output=True, text=True, check=False)
    
    result = process.stdout.strip()
    log.debug(f"=>get_command - filename: {filename} path: {result}")
    return result   



def search_for_exe(filename: str, expected_directory: str) -> str | None:
    # Not yet implemented for macos or linux.  This is a windows only function for now.
    if config['my_os'] != 'win':
        log.debug(f"search_for_exe is not implemented for {config['my_os']}")
        return None
    
    likely_paths = []   # arraay of Path objects, not strings.
    already_searched = set()  # set of Path objects, not strings.

    vs_code_parent = None
    vs_code_path_str = get_command_path('code')
    if vs_code_path_str:
        vs_code_path = Path(vs_code_path_str)
        vs_code_root = vs_code_path.parent.parent
        log.debug(f"VSCode root: {vs_code_root}")
        vs_code_parent = vs_code_root.parent
        # print(path.parent.absolute())
        log.debug(f"VSCodeParent: {vs_code_parent}")
        likely_paths.append(vs_code_parent)


    likely_paths.extend([
        Path("C:/Program Files"),
        Path("$env:LocalAppData/Programs"),
        Path("$env:LocalAppData")
        ])
    
    for path in likely_paths:
        log.info(f"Searching likely path {path} for {filename} in find-executable.ps1 ...")
        # $Result = Get-Childitem -Path $Path -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
        result = scan_sub_directories(path)
        already_searched.add(path)
        if result: 
            log.debug(f"{filename} found in likely path {path}")
            correct_directory = check_directory(result.name, path, expected_directory)
            if correct_directory: 
                return correct_directory

    # Search the directories in the PATH environment variable for the executable
    envirnment_paths = os.environ.get('PATH', '').split(os.pathsep)
    for path_str in envirnment_paths:
        path = Path(path_str)
        if path in already_searched:
            continue
        log.info(f"Searching env:Path {path} for {filename} in find-executable.ps1 ...")
        result = scan_sub_directories(path)
        already_searched.add(path)
        if result: 
            log.debug(f"{filename} found in environment path {path}")
            correct_directory = check_directory(result.name, path_str, expected_directory)
            if correct_directory: 
                return correct_directory

    log.info(f"Searching C drive for {filename}...")
    result = scan_sub_directories(Path('C://'))
    already_searched.add(Path("C:/"))
    if result:
        parent_dir = Path(result.name).parent
        log.debug(f"{filename} found on C drive in {parent_dir}")
        correct_directory = check_directory(result.name, parent_dir.name, expected_directory)
        if (correct_directory): 
            return correct_directory

    return None

def find_executable(filename: str, expected_directory: str = '') -> str | None:
    # In future we might do this in Python, but for now we will use scripts.
    # Reasons:
    # 1 Only implemented for Windows, so no point being cross-platform.
    # 2. Have to resort to Powershell/Bash for 'Get-Command'
    # 3. Running steps as Python scripts would ne novel/brave at this time.
    
    cached_path = get_context(filename, 'file_paths')
    if cached_path:
        log.debug(f"{filename} found in cache")
        return cached_path

    result = get_command_path(filename)
    if result:
        log.debug(f"{filename} is a known command")
        
        if expected_directory == '':
            set_context(filename, result, 'file_paths')
            return result

        correct_directory = check_directory(filename, result, expected_directory)
        if correct_directory:
            set_context(filename, correct_directory, 'file_paths')
            return correct_directory

    result = search_for_exe(filename, expected_directory)
    if result:
        if expected_directory == '':
            set_context(filename, result, 'file_paths')
            return result
        
        correct_directory = check_directory(filename, result, expected_directory)
        if correct_directory:
            set_context(filename, correct_directory, 'file_paths')
            return correct_directory

    return None

