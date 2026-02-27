function Invoke-Retry-Failures {
    WriteInfo "Retry attempt $RetryAttempt. Retrying in 3 seconds..."
    Start-Sleep -Seconds 3

    if ($RetryAttempt -lt $MAX_RETRIES) { 
        . $PSScriptRoot/../setup-nhsapp.ps1 -Trigger batch
    } else {
        Remove-Item -Path "$WORKING_DIR\retry-attempts.txt"
    }

}

