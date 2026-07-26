#Requires -Version 7
Set-StrictMode -Version 3.0

if (Test-Path variable:INIT_WIN) { return }
write-Output "=>init.ps1"

$Script:INIT_WIN = 1
$Script:CURRENT_STEP = ''

$Script:FORCE = $false
$Script:DEBUG = $true
if ($DebugPreference -eq 'Continue') { $Script:DEBUG = $true }
if ("CPC-NIET2-AY8UE DESKTOP-2022".Contains($env:ComputerName)) { $Script:DEBUG = $true}

if (!(Test-Path variable:P1_ROOT_SCRIPT)) { 
    $Script:P1_ROOT_SCRIPT = (get-item $PSScriptRoot)
}

if (!(Test-Path variable:P1_ROOT_WIN)) { 
    $Script:P1_ROOT_WIN = (get-item $PSScriptRoot).Parent.Parent.FullName
}

$Libraries = Get-Childitem -Path "$P1_ROOT_SCRIPT\lib" -Include '*.ps1' -Exclude config_base.ps1, z*.ps1 -File -Recurse -ErrorAction SilentlyContinue
$index=0
foreach ($Library in $Libraries) {
    Write-Progress -Activity "Loading library" -Status "$index of $($Libraries.Count)" -CurrentOperation "$($Library.Name)" -PercentComplete (($index / $Libraries.Count) * 100)
    # Write-output "Loading library $index of $($Libraries.Count) - $($Library.Name)"
    . "$($Library.FullName)"
    $index+=1
}
. $PSScriptRoot\lib\conf\config_base.ps1 # Load config last since it is not just a function definiton.

set_repo_dir
$Script:REPO_DIR = get_context repo_dir

get_next_run_id

# if (!(Test-Path -PathType Container $WORKING_DIR)) {
#     New-Item -Path $WORKING_DIR -ItemType Directory | Out-Null
#     New-Item -Path $WORKING_DIR\keybase -ItemType Directory | Out-Null
#     New-Item -Path $WORKING_DIR\activity_sort -ItemType Directory | Out-Null
#     New-Item -Path $WORKING_DIR\test_results -ItemType Directory | Out-Null
# }


# $GCM_PATH_WIN = Find-GCM-Executable
# $GCM_PATH_WSL = Get-Unix-Path $GCM_PATH_WIN

get_context
show_config
