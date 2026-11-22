param (
    [Parameter(Position=0)]
    [string]$Command,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# This is the primaary entry point before installation.
# Sets P1_ROOT_WIN, then hands over to terminal_login.ps1, 
# which will set up the environment and launch the main p1.py script.
# If P1 is already installed, run p1.py directly, without calling terminal_login.ps1.

Set-StrictMode -Version 3.0

# $ErrorActionPreference = "Stop"

if (!(Test-Path variable:P1_ROOT_WIN)) { 
    Write-output "Setting P1_ROOT_WIN manually"
    $Script:P1_ROOT_WIN = (get-item $PSScriptRoot)
}

if (!(Test-Path variable:P1_ROOT_SCRIPT)) {
    $Script:P1_ROOT_SCRIPT = "$P1_ROOT_WIN/pipeline1/scripts"
}

# $script="$P1_ROOT_SCRIPT/edit_login_profile.ps1"
# if (!(Test-Path -Path $script -PathType Leaf)) {
#     $script = Get-Childitem -Path "$P1_ROOT_SCRIPT" -Include 'edit_login_profile.ps1' -Recurse
#     if (Test-Path -Path $script -PathType Leaf) {
#         ## & $script
#         # . $script.FullName
#     } else {
#         Write-Output "Could not find edit_login_profile.ps1 in $P1_ROOT_SCRIPT"
#     }
# }

# When P1 is invoke from the command line, clear the new_tab_queue
new_tab_queue_dir="$HOME/.pipeline1/working/new_tab_queue"
if (Test-Path -Path $new_tab_queue_dir -PathType Container) {
    Get-ChildItem -Path $new_tab_queue_dir | Remove-Item -Force
}

$required_libraries = @(
    'logging.ps1',
    'get_context.ps1',
    'set_context.ps1',
    'get_onedrive_info.ps1',
    'get_wsl_win_info.ps1',
    'process_new_tab_file.ps1',
    'switch_python_version.ps1',
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

$invoke_dir = (Get-Location).Path
$Global:P1_INVOKE_DIR = $invoke_dir
set_context 'p1_invoke_dir' $invoke_dir

$profile_path = $PROFILE.CurrentUserCurrentHost
$profile_content = if ($profile_path) {
    Get-Content -Path $profile_path -ErrorAction SilentlyContinue
}
$search_terms = @(
    'pipeline1_v',
    'workstation1_v'
)

if ($profile_content -imatch ($search_terms -join '|')) {
    python "$P1_ROOT_WIN/pipeline1/p1.py" $Command $Arguments
    exit 0
}


$script="$P1_ROOT_SCRIPT/terminal_login.ps1"
if (!(Test-Path -Path $script -PathType Leaf)) {
    Write-Output "Searching for terminal_login.ps1 in p1.ps1..."
    $script = Get-Childitem -Path "$P1_ROOT_SCRIPT" -Include 'terminal_login.ps1' -Recurse
    if (Test-Path -Path $script -PathType Leaf) {
        Write-Output "Found terminal_login.ps1"
        . $script.FullName
    } else {
        Write-Output "Could not find terminal_login.ps1 in $P1_ROOT_SCRIPT"
    }
}
