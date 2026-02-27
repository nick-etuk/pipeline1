function Get-Step-Name {
    param (
        $PartialName
    )

    $Result = ""
    $MyMatches = [System.Collections.ArrayList]@()
    $MyMatches.Clear()

    foreach($item in $Steps) {
        $StepName = $item.Name
        if ($StepName -eq $PartialName) {
            $Result = $StepName
            break 
        }
        if ($StepName -match $PartialName) {
            $MatchCount += 1
            $MyMatches.add($StepName) | Out-Null
        }
    }

    if($Result) { return $Result}
    if($MyMatches.Count -eq 1) { return $MyMatches[0] }
    
    if($MyMatches.Count -gt 1) { 
        WriteInfo "Multiple matches found for $PartialName"
        WriteInfo $myMatches
        WriteInfo "No steps will be removed"
    }

    return ""    
}