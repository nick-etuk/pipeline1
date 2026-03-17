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
    'config_dynamic.ps1',
    'add_aliases.ps1',
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



$new_tab_queue="$WORKING_DIR/new_tab_queue"
if(Test-Path -PathType Container -Path $new_tab_queue) {
    $files = Get-ChildItem -Path $new_tab_queue
    $file_count = ($files | Measure-Object).Count
    if ($file_count -gt 0) {
        Write-Output "Tasks found in New Tab queue..."
        . $P1_ROOT_SCRIPT/init.ps1
        $oldest_file = $files | Sort-Object LastWriteTime | Select-Object -First 1
        process_new_tab_file $oldest_file.FullName
        return
    }
}

$startup_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'p1.py' -exclude '.venv_p1' -Recurse -File -ErrorAction SilentlyContinue
if ($startup_script -eq $null) { 
  Write-Output "Could not find Pipeline startup script p1.py in $P1_ROOT_WIN"
  exit 0
}

# todo: decide how to manage venvs
# create_venv 'p1'
# activate_venv 'p1'
# install_py_packages 'p1'
python $startup_script.FullName $Command $Arguments

$default_step_path=$(Get-Config 'default_step_path')
if ($default_step_path -and (Test-Path -Path $default_step_path -PathType Container)) {
    Set-Location -Path $default_step_path
}
