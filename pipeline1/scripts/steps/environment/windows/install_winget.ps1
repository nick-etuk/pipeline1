. $PSScriptRoot\install-ui-xaml.ps1

function InstallWinGet {

    if (!(Invoke-Step-Entry)) { return }

    Install-Module -Name WingetTools
    Install-UI-Xaml
    
    # Call Install-Winget from a separate process
    # because it tries to restart the PC and fails
    # in a way that cannot be caught.
    Start-Process pwsh -ArgumentList "-NoExit", "-f", "$PSScriptRoot\child-process-install-winget.ps1"
    
    Invoke-Step-Exit
}