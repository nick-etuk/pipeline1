function Assert-Ok-To-Proceed {
    Param (
        [Parameter(Mandatory=$true)]
        $Step
    )
    if ($Force) { return $true }

    # if ($global:RunMode -eq "single-step") { 
    #     return HardCheckDependencies -Step $Step
    # }

    # return SoftCheckDependencies -Step $Step
    return HardCheckDependencies -Step $Step
}
