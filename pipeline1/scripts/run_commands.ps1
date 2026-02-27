$ErrorActionPreference = 'Continue'

. $PSScriptRoot\init.ps1

$Checks = @()
function invoke_commands($commands) {
    foreach ($command in $commands) {
        $passed = $false
        $status = Invoke-Expression $command
        if ($status) { $passed = $true }
        if (!$passed) {
            WriteInfo "Command failed: $command"
            WriteInfo "Status: $status"
            return 1 
        }
        WriteInfo "Command successful: $command"
    }
    return 0
}

invoke_commands @() 
