# Pipeline1_v{{P1_VERSION}} start
$global:P1_ROOT_WIN = '{{P1_ROOT_WIN}}'
if ($env:PATH -notlike "*$P1_ROOT_WIN*") {
    write-output "Adding Pipeline1 root to PATH"
    $env:PATH += ";$P1_ROOT_WIN"
}

$global:WORKING_DIR = '{{WORKING_DIR}}'
$login_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'terminal_login.ps1' -Recurse -File -ErrorAction SilentlyContinue
if (-not $login_script) {
    Write-Error "terminal_login.ps1 not found in $P1_ROOT_WIN"
}
$Script:P1_ROOT_SCRIPT = $login_script.Directory

. "$P1_ROOT_SCRIPT\terminal_login.ps1"
# Pipeline1_v{{P1_VERSION}} end
