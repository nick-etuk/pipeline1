param (
    [Parameter(Position=0)]
    [string]$Command,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

$ErrorActionPreference = "Stop"

if (!(Test-Path variable:P1_ROOT_WIN)) { 
    $Script:P1_ROOT_WIN = (get-item $PSScriptRoot)
    Write-output "Manually set P1_ROOT_WIN to $P1_ROOT_WIN"
}

# $init_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'init.ps1' -exclude $VENV_DIR -File -Recurse -ErrorAction SilentlyContinue
# $VENV_DIR = Get-Childitem -Path "$P1_ROOT_WIN" -Include '.venv_p1' -Directory -Recurse
# $init_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'init.ps1' -Recurse | Where-Object { $_.FullName -notlike "*$($VENV_DIR.Name)*" }
$init_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'init.ps1' -Recurse
if (-not $init_script) {
    Write-Error "init.ps1 not found in $P1_ROOT_WIN. Aborting."
}

$Script:P1_ROOT_SCRIPT = $init_script.Directory
. $init_script



$startup_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'p1.py' -exclude '.venv_p1' -Recurse -File -ErrorAction SilentlyContinue
python $startup_script.FullName $Command $Arguments

# $default_step_path=$(Get-Config 'default_step_path')
# if ($default_step_path -and (Test-Path -Path $default_step_path -PathType Container)) {
#     Set-Location -Path $default_step_path
# }
