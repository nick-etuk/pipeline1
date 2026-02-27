function get_step_path ([parameter(Mandatory=$true)]$StepID) {
    $StepRegistry = "$WORKING_DIR/step_registry.csv"
    if (!(Test-Path -PathType Leaf $StepRegistry)) {
        Write-Warning "Step registry file $StepRegistry not found"
        # update_step_registry
    }
    $StepID = $StepID.ToLower() -replace '-', '_'

    $StepPath = Get-Content $StepRegistry | Where-Object { $_ -match "^$StepID," } | ForEach-Object { $_.Split(',')[3] }
    if ($StepPath) { return $StepPath }
    $StepID = "`"$StepID`""
    $StepPath = Get-Content $StepRegistry | Where-Object { $_ -match "^$StepID," } | ForEach-Object { $_.Split(',')[3] }
    return $StepPath
}

function get_step_config ([parameter(Mandatory=$true)]$StepID) {
    $FilePath = get_step_path -StepID $StepID
    if (!$FilePath) { return }
    $Content = Get-Content $FilePath -ErrorAction SilentlyContinue | Out-String
    $Json = ConvertFrom-Json -InputObject $content -ErrorAction SilentlyContinue
    return $Json
}
