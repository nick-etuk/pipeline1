function RunStep {
    param (
        [parameter(Mandatory=$true)]
        $StepID,
        [string[]]$Arguments=@()
    )
    $RunOnce = 'false'
    $RunAlways = 'false'
    $ArgCount = $Arguments.Count
    $AllPassed = 0

    $StepID = $StepID.ToLower() -replace '-', '_'

    $StepConfig = get_step_config -StepID $StepID

    if (!$StepConfig) {
        WriteInfo "Config not found for step $StepID in $P1_ROOT_WIN\steps"
        return 1
    }

    if ($StepConfig | Get-Member -Name 'os') {
        $StepOS = $StepConfig.os
        if ("unix ubuntu macos".Contains($StepOS)) {
            WriteInfo "$StepID not for Windows"
            return 0
        }
    }

    if ($StepConfig | Get-Member -Name 'runOnce') {
        $RunOnce = $StepConfig.runOnce
        if ($RunOnce -eq 'true' ) {
            $Key="step_$StepID"

            if ($ArgCount -gt 0) {
                $FormattedArgs = $($Arguments -join "_")
                $Key="step_$StepID_$FormattedArgs"
            }

            $Status = Get-config $Key status

            if ($Status -eq 'done' ) {
                WriteInfo "$StepID step already done"
                return 0
            }
        }
    }

    if ($StepConfig | Get-Member -Name 'runAlways') {
        $RunAlways = $StepConfig.runAlways
    }

    if ($RunAlways -ne 'true' ) {
        $OkToProceed = Invoke-Step-Entry -Step $StepID -Arguments $Arguments
        if (!$OkToProceed) { return }
    }

    WriteInfo "$StepID step started"

    if ($StepConfig | Get-Member -Name 'commands') {
        $StepCommands = $StepConfig.commands
        foreach($Command in $StepCommands) {
            Invoke-Expression $Command
        }
    }

    if ($StepConfig | Get-Member -Name 'steps') {
        $ChildSteps = $StepConfig.steps
        RunChildSteps -ChildSteps $ChildSteps -ParentArgs $Arguments
        if ($? -ne 0 ) { $AllPassed = 1 }
    }

    $StepConfigFile = get_step_path -StepID $StepID
    $StepDir = Split-Path -Path $StepConfigFile -Parent
    $ScriptFile = "$StepDir/$StepID.ps1"
    if (!(Test-Path -PathType Leaf $ScriptFile)) { return $AllPassed }

    . "$ScriptFile" -Arguments $Arguments

    # if (Test-Path -PathType Leaf "$StepDir\$StepFileName.sh") {
    #     get-ScriptRootUnix
    #     WriteWarn "Running foreign step $StepID $Arguments in WSL"
    #     wsl -u $P1_USER_UNIX -- "$P1_ROOT_UNIX/core/lib/run_step/run_step.sh" "$StepFileName" "$Arguments"
    #     $AllPassed = Invoke-Step-Exit -Step $StepID -Arguments $Arguments
    #     return
    # }

    if ($RunAlways -ne 'true' ) {
        Invoke-Step-Exit -Step $StepID -Arguments $Arguments
        if ($? -ne 0 ) { $AllPassed = 1 }
    }

    if ($AllPassed -eq 0 ) {
        WriteInfo "$StepID step completed"
        if ($RunOnce -eq 'true' ) { Set-Config $Key 'done'  status }
    }
    return $AllPassed
}
