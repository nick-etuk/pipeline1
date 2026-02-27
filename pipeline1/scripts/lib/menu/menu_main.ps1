function Show-Main-Menu {
    WriteInfo "`nWelcome to pipeline1`n`n"

    $ProjectRegistry = "$WORKING_DIR/project_registry.csv"
    if (!(Test-Path -Path $ProjectRegistry)) {
        WriteWarning "Project registry not found at $ProjectRegistry"
        return
    }

    $ProjectRegistryContent = Import-CSV $ProjectRegistry
    if (!$ProjectRegistryContent) {
        WriteWarning "Project registry is empty or could not be read: $ProjectRegistry"
        return
    }
    $ProjectRegistryContent = $ProjectRegistryContent | Sort-Object -Property display_order

    $ActivityRegistry = "$WORKING_DIR/activity_registry.csv"
    if (!(Test-Path -Path $ActivityRegistry)) {
        WriteWarning "Activity registry not found at $ActivityRegistry"
        return
    }
    $ActivityRegistryContent = Import-CSV $ActivityRegistry
    # $ActivityRegistryContent = Get-Content -Path $ActivityRegistry -ErrorAction Stop | ConvertFrom-Csv -Delimiter ','
    #  -Header 'activity_id', 'project
    # $data[0] = 'Num' + $data[0]
    # $data | ConvertFrom-Csv
    # $ActivityRegistryContent = Get-Content -Path $ActivityRegistry
    # writedebug "ActivityRegistryContent: $ActivityRegistryContent"
    if (!$ActivityRegistryContent) {
        WriteWarning "menu: Activity registry could not be read: $ActivityRegistry"
        return
    }
    $ActivityRegistryContent = $ActivityRegistryContent | Sort-Object -Property display_order


    foreach ($ProjectLine in $ProjectRegistryContent) {
        $ProjectID = $ProjectLine.project_id
        $DisplayOrder = $ProjectLine.display_order
        $ProjectTitle = $ProjectLine.title

        $BorderLine = '-' * $ProjectTitle.Length

        WriteInfo "`n$BorderLine"
        WriteInfo $ProjectTitle
        WriteInfo $BorderLine

        foreach ($ActivityLine in $ActivityRegistryContent) {
            $ActivityProject = $ActivityLine.project_id
            if ($ActivityProject -ne $ProjectID) { continue }
            $ActivityID = $ActivityLine.activity_id
            $ActivityTitle = $ActivityLine.title

            WriteInfo "$ActivityID`t $ActivityTitle"
        }
    }
    # WriteInfo "`nTo show this menu again, enter the command 'p1'."
    $StartupScript = Get-Childitem -Path "$P1_ROOT_WIN\core" -Include 'p1.ps1' -File -Recurse -ErrorAction SilentlyContinue
    if (-not $StartupScript) {
        WriteError "Startup script p1.ps1 not found in $P1_ROOT_WIN\core."
        return
    }
    WriteInfo "The script p1.ps1 is located at $(Split-Path -Path $StartupScript.FullName -Parent)"
}