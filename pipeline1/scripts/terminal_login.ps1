param (
    [Parameter(Position=0)]
    [string]$Command,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

Set-StrictMode -Version 3.0

if ($env:TERM_PROGRAM -and $env:TERM_PROGRAM -ne 'Windows Terminal') {
    exit 0
}
writeDebug '=>terminal_login.ps1: Starting Pipeline1 terminal login script...'
$required_libraries = @(
    'logging.ps1',
    'config_dynamic.ps1',
    'add_aliases.ps1',
    'add_to_path.ps1',
    'install_pyenv.ps1',
    'create_venv.ps1',
    'pip_install.ps1',
    'config_base.ps1'  # source this last since it is a script, not a function.
)
foreach ($lib in $required_libraries) {
    $lib_path = Get-ChildItem -Path "$P1_ROOT_SCRIPT\lib" -Include $lib -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $lib_path) {
        Write-Error "Required library $lib not found"
        exit 1
    }   
    . $lib_path.FullName
}

& $P1_ROOT_SCRIPT\vm\dev_box\unschedule_first_login.ps1
# "$P1_ROOT_SCRIPT\vm\dev_box\unschedule_first_login.ps1"
add_aliases
add_to_path


$new_tab_queue="$WORKING_DIR/new_tab_queue"
if(-not Test-Path -PathType Container -Path $new_tab_queue) {
    New-Item -Path $new_tab_queue -ItemType Directory -Force | Out-Null
}

$queue_files = Get-ChildItem -Path $new_tab_queue
$queue_length = ($queue_files | Measure-Object).Count
if ($queue_length -gt 0) {
    WriteInfo "Tasks found in New Tab queue..."
    . $P1_ROOT_SCRIPT/init.ps1
    $oldest_file = $queue_files | Sort-Object LastWriteTime | Select-Object -First 1
    process_new_tab_file $oldest_file.FullName
    return
} else {
    if (-not Get-Command python -ErrorAction SilentlyContinue) {
		$continue = read-host "Install Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION via Pyenv (y/n)?"
        if ($continue.ToLower() -ne 'y') {
            Write-Host "Skipping Python installation. Exiting..."
            exit 0
        }
		install_pyenv
	}
	
    if (-not $env:VIRTUAL_ENV) {
        create_venv('p1')
    }
	
    if (!pip_install('p1')) {
		writeError 'Error installing Python packages'
		exit 1
	}
    python "$P1_ROOT_WIN/pipeline1/p1.py" $Command $Arguments
}

$startup_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'p1.py' -exclude '.venv_p1' -Recurse -File -ErrorAction SilentlyContinue
if ($startup_script -eq $null) { 
  Write-Output "Could not find Pipeline startup script p1.py in $P1_ROOT_WIN"
  exit 0
}

# todo: decide how to manage venvs
# create_venv
# pip_install

$default_step_path=$(get_context 'default_step_path')
if ($default_step_path -and (Test-Path -Path $default_step_path -PathType Container)) {
    Set-Location -Path $default_step_path
}
