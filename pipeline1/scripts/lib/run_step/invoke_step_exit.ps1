function Invoke-Step-Exit {
    Param (
        [Parameter(Position=0)]
        $Step,
        [Parameter(Position=1)]
        $Arguments
    )

    if (!$Step) {
        $CallingFunction = [string]$(Get-PSCallStack)[1].FunctionName
        if ($Callingfunction -eq "<ScriptBlock>") {
            $CallingFunction = $CallingScript
        }
        $Step = $CallingFunction
    }

    $TestResults = Assert-Step-Done -Step $Step -Arguments $Arguments
    # $Passed = $true
    # foreach ($Test in $TestResults) {
    #     if (!$Test.passed) {
    #         $Passed = $false
    #         WriteInfo "Step failed" -Step $Step
    #         Set-Step-Status -Step $Step -Status "failed"
    #         write-verbose "Test: $($Test.condition)"
    #         write-verbose "Expected: $($Test.expectedResults)"
    #         write-verbose "Received: $($Test.actualResults)"
    #         write-verbose "Passed? $($Test.passed)"
    #         break
    #     } 
        # else {
        #     WriteDebug "$Step done"
        #     WriteDebug "Test: $($Test.condition)"
        #     WriteDebug "Expected: $($Test.expectedResults)"
        #     WriteDebug "Received: $global:ActualResults"
        # }
    # }

    # if ($TestResults.allPassed) {
    #     writeInfo "$Step step completed"
    #     Set-Step-Status -Step $Step -Status "done"
    # }
}
