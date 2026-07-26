function old_get_next_run_id {
    if ($global:Debug) { return "001" }
    
    $LAST_RUN_ID_FILE = "$WORKING_DIR\last-runid.txt"
    if (!(Test-Path -PathType Leaf $LAST_RUN_ID_FILE)) {
       New-Item -Path $LAST_RUN_ID_FILE -ItemType File | Out-Null
        $Result = 1
    } else {
        $CurrentValue = Get-Content -Path $LAST_RUN_ID_FILE

        # Stop incrementing RUN_ID once setup has been completed
        if (!(Test-Path -PathType Leaf "$WORKING_DIR\setup-web-complete.txt")) {
            $Result = [int]$CurrentValue
        } else {
            $Result = [int]$CurrentValue + 1
        }
    }
    $Result = $Result.ToString("000")
    Out-File -FilePath $LAST_RUN_ID_FILE -InputObject $Result
    return $Result
}

function get_next_run_id {
    if ($DEBUG) { 
        $RUN_ID = "001"
        return
    }
    write-output "Getting next run ID..."
    $LastRunId = (Get-ChildItem $LOG_BASE -Directory | Sort-Object | Select-Object -Last 1).Name
    $RUN_ID = ([Int]$LastRunId + 1).ToString("000")
    write-output "RUN_ID: $RUN_ID"
    return
}
