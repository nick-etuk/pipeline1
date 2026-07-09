function Set-Step-Status {
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $Step,
        [Parameter(Mandatory=$true)]
        [string]
        $Status
    )

    $Step = $Step.ToLower()
    foreach($item in $Steps) {
        if ($item.name.ToLower() -eq $Step) {
            $item.status = $Status
            break
        }
    }
}
