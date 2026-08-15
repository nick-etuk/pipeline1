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
$required_libraries = @(
    'get_next_run_id.ps1',
    'logging.ps1',
    'get_context.ps1',
    'set_context.ps1',
    'add_aliases.ps1',
    'add_to_path.ps1',
    'process_new_tab_file.ps1',
    'install_pyenv.ps1',
    'switch_python_version.ps1',
    'create_venv.ps1',
    'activate_venv.ps1',
    'pip_install.ps1',
    'set_repo_dir.ps1',
    'edit_login_profile.ps1',
    'config_base.ps1'  # source this last since it is a script, not a function.
)

$index=0
foreach ($lib in $required_libraries) {
    # Write-output "Searching for library $lib in terminal_login.ps1"
    $lib_path = Get-ChildItem -Path "$P1_ROOT_SCRIPT\lib" -Include $lib -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $lib_path) {
        Write-Error "Required library $lib not found"
        exit 1
    }
    # Write-output "Loading $lib"
    . $lib_path.FullName
    $index+=1
}

# "$P1_ROOT_SCRIPT\vm\dev_box\unschedule_first_login.ps1"
# & $P1_ROOT_SCRIPT\vm\dev_box\unschedule_first_login.ps1 # use this if needed in dev boxes.
add_aliases
add_to_path
edit_login_profile

if (Test-Path variable:P1_INVOKE_DIR) {
    set_context 'p1_invoke_dir' "$P1_INVOKE_DIR"
}

$new_tab_queue="$WORKING_DIR/new_tab_queue"
if (!(Test-Path -PathType Container -Path $new_tab_queue)) {
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
    if (!((Get-Command python -ErrorAction SilentlyContinue) -and (Get-Command pyenv -ErrorAction SilentlyContinue))) {
		$continue = read-host "Install Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION using Pyenv (y/n)?"
        if ($continue.ToLower() -ne 'y') {
            Write-output "Skipping Python installation. Exiting..."
            exit 0
        }
		install_pyenv
	}
	
    switch_python_version
    create_venv 'p1'
    activate_venv 'p1'
    pip_install 'p1'

    python "$P1_ROOT_WIN/pipeline1/p1.py" $Command $Arguments
}

# todo: does this do anything? It seems to be a leftover from an earlier version of the script.   
# $startup_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'p1.py' -exclude '.venv_p1' -Recurse -File -ErrorAction SilentlyContinue
# if ($startup_script -eq $null) { 
#   Write-Output "Could not find Pipeline startup script p1.py in $P1_ROOT_WIN"
#   exit 0
# }

# todo: decide how to manage venvs
# create_venv
# pip_install

set_repo_dir
$default_step_path=$(get_context 'default_step_path')
if ($default_step_path -and (Test-Path -Path $default_step_path -PathType Container)) {
    Set-Location -Path $default_step_path
}
