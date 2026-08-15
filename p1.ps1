# This is the primaary entry point before installation.
# Sets P1_ROOT_WIN, then hands over to terminal_login.ps1, 
# which will set up the environment and launch the main p1.py script.

# $ErrorActionPreference = "Stop"
$invoke_dir = (Get-Location).Path
$Global:P1_INVOKE_DIR = $invoke_dir

if (!(Test-Path variable:P1_ROOT_WIN)) { 
    Write-output "Setting P1_ROOT_WIN manually"
    $Script:P1_ROOT_WIN = (get-item $PSScriptRoot)
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
