function Invoke-Single-Step {
param (
    [Parameter(Position=0)]
    $StepParam
)

    # $Steps = Get-Steps-List
    $Step = Get-Step-Name -PartialName $StepParam
    if (!$Step) {
        WriteInfo "Unable to work out which step to run from $StepParam"
        WriteInfo "Specify a string which uniquely matches only one step"
        WriteInfo "or specify the full step name. Here is a list of the steps:"

        $Steps.foreach({ WriteInfo $_.name })

        exit
    }

    WriteInfo "Running individual step $Step"
    $global:RunMode = "single-step"
    HardCheckDependencies -Step $Step
    $ScriptBlock = (get-command $Step -CommandType Function).ScriptBlock
    Invoke-Command -Scriptblock $ScriptBlock
}
