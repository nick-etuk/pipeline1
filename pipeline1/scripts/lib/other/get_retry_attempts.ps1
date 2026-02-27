Function Get-Retry-Attempts {
    param (
        [Parameter(Position=0)]
        $RetryAttemptFile
    )
    if (!(Test-Path -PathType Leaf "$WORKING_DIR\$RetryAttemptFile")) {
        New-Item -Path "$WORKING_DIR\$RetryAttemptFile" -ItemType File | Out-Null
        $Result = 0
    } else {
        $CurrentValue = Get-Content -Path "$WORKING_DIR\$RetryAttemptFile"
        $Result = [int]$CurrentValue + 1
    }
    WriteInfo $Result | Out-File -FilePath "$WORKING_DIR\$RetryAttemptFile"
    return $Result
}
