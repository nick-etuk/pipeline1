# Pipeline1_v{{P1_VERSION}} start
$global:P1_ROOT_WIN = '{{P1_ROOT_WIN}}'
$global:P1_ROOT_SCRIPT="$P1_ROOT_WIN\pipeline1\scripts"

if ($env:PATH -notlike "*$P1_ROOT_SCRIPT*") {
    write-output "Adding Pipeline1 root to PATH"
    $env:PATH += ";$P1_ROOT_SCRIPT"
}

$global:WORKING_DIR = '{{WORKING_DIR}}'
$login_script = "$P1_ROOT_SCRIPT\terminal_login.ps1"
if (-not (Test-Path -PathType Leaf $login_script)) {
    write-output "terminal_login.ps1 not found in $P1_ROOT_SCRIPT. Searching for it in $P1_ROOT_WIN..."
    $login_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'terminal_login.ps1' -Recurse -File -ErrorAction SilentlyContinue
    if (-not $login_script) {
        write-output "terminal_login.ps1 not found in $P1_ROOT_WIN"
        exit 0
    }
    $Script:P1_ROOT_SCRIPT = $login_script.Directory
}

. "$P1_ROOT_SCRIPT\terminal_login.ps1"
# Pipeline1_v{{P1_VERSION}} end
