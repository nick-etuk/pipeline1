function Get-Step-Status {
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $Step
    )

    $Result = $null
    $Step = $Step.ToLower()
    foreach($item in $Steps) {
        if ($item.name.ToLower() -eq $Step) {
            $Result = $Status
            break
        }
    }
    return $Result
}
