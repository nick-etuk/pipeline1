function Read-Bash-Logs {
    Param (
        $LogFile
    )
    return
    
    $CallingFunction = [string]$(Get-PSCallStack)[1].FunctionName
    if ($Callingfunction -eq "<ScriptBlock>") {
        $CallingFunction = $CallingScript
    }
    $Step = $CallingFunction.ToLower()

    if (Select-String -Path $LogFile -Pattern "Step complete") { Set-Status -Step $Step -Status "done" }
    if (Select-String -Path $LogFile -Pattern "Step skipped") { Set-Status -Step $Step -Status "done" }
    if (Select-String -Path $LogFile -Pattern "Step failed") { Set-Status -Step $Step -Status "failed" }
}