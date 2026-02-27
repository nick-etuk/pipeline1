function CheckAssertion {
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $Actual,
        [Parameter(Mandatory=$true)]
        [string]
        $Expected
    )

    $Actual = $Actual.trim()
    $Actual = $Actual -replace [char]0 # convert to utf8
    
    if ($Expected -eq "not empty") {
        if ($Actual) { return $true }
    }
    
    if ($Expected -eq "empty") {
        if (!$Actual) { return $true }
    }

    if ($Actual -match $Expected) { return $true }

    return $false
}