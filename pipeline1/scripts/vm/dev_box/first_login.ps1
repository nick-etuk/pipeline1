Start-Transcript -Path "C:\provisioning\log\first-login.log" -Append -IncludeInvocationHeader
Start-Process C:\Provisioning\scripts\core\doc\troubleshooting\general.html

# . $PSScriptRoot\..\..\init.ps1
. $PSScriptRoot\..\..\cli\p1.ps1
# . $PSScriptRoot\windows\user\get-git-repos-win.ps1
# . $PSScriptRoot\windows\user\set-windows-user-env.ps1
# . $PSScriptRoot\windows\user\install-winget.ps1
# . $PSScriptRoot\windows\user\install-ui-xaml.ps1
# . $PSScriptRoot\windows\user\install-ps7.ps1


# Set-Windows-User-Env

# # Get-Git-Repos-Win
# Install-UI-Xaml
# InstallWinGet
# Install-PS7

Stop-Transcript | Out-Null

# Start-Process pwsh -ArgumentList "-NoExit", "-f", "$PSScriptRoot\install-apps.ps1"
# . $PSScriptRoot\install-apps.ps1 -NoInit

