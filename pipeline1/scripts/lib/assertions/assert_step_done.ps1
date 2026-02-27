function Assert-Step-Done {
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $Step,
        $Arguments
    )
    # writedebug "=>Assert-Step-Done $Step"

    $Tests = [System.Collections.ArrayList]@()
    $Tests.Clear()
    $Checks = @()
    $AllPassed = $false


    $CallingFunction = [string]$(Get-PSCallStack)[1].FunctionName
    if ($CallingFunction -eq "<ScriptBlock>") {
        $CallingFunction = $CallingScript
    }

    $StepConfig = get_step_config -StepID $Step
    if ($StepConfig | Get-Member -Name 'checks') { 
        $StepConfigChecks = $StepConfig.checks
        if ($StepConfigChecks | Get-Member -Name 'win') { $Checks = $StepConfig.checks.win }
    }

    if ($Step -eq "start_docker") {
        $Checks = @("(wsl -u $P1_USER_UNIX docker stats --no-stream) -match 'CONTAINER'")
    }

    if ($Script:Force) {
        if ($config_file -like "*core/*") {
            if ($calling_function -eq 'Invoke-Step-Entry') {
                WriteInfo "$Step is a core step, so we will not force it."
            }
        } else {
            if ($calling_function -eq 'CheckDependencies') {
                WriteInfo "Forcibly passing dependency $Step"
                return 0
            }
            if ($calling_function -eq  'Invoke-Step-Entry') {
                WriteInfo "Forcing $Step"
                return 1
            }
        }
    }
    
    if ($Checks.length -eq 0) {
        # WriteWarning "No checks for $Step"
        if ("Invoke-Step-Exit CheckDependencies".Contains($CallingFunction)) {
            $TestResults = @{
                allPassed = $true
                tests = @()
            }
            return $TestResults
        }
        $TestResults = @{
            allPassed = $false
            tests = @()
        }
        return $TestResults
    }
    
    
    $AllPassed = $true
    foreach ($Check in $Checks) {
        $Passed = $false
        if (Invoke-Expression $Check) { $Passed = $true }

        $Test = @{
            check = $Check
            passed = $Passed
        }
        $Tests.Add($Test) | Out-Null
        if (!$Passed) {
            $AllPassed = $false

            if ($CallingFunction -eq "Invoke-Step-Exit") {
                WriteInfo "$Step step failed"
                WriteInfo "Check: $Check"
                WriteInfo "Passed: $Passed"
        
                Show-Help -Step $Step
            }
            break
        }
    }

    $TestResults = @{
        allPassed = $AllPassed
        tests = $Tests
    }
    return $TestResults
}