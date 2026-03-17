function get_project_path {
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $project_id
    )
    
    if ($project_id -eq "p1") {
        $project_id = "pipeline1"
        return $P1_ROOT
    }

    $ProjectRegistry = "$WORKING_DIR/project_registry.csv"
    if (!(Test-Path -Path $ProjectRegistry)) {
        WriteError "Project registry not found at $ProjectRegistry"
        return
    }

    # $RegistryContent = Get-Content -Path $RegistryFile -ErrorAction SilentlyContinue
    $RegistryContent = Import-CSV $ProjectRegistry
    if (!$RegistryContent) {
        WriteError "Project registry is empty or could not be read: $RegistryFile"
        return
    }
    foreach ($Line in $RegistryContent) {
        $SortOrder = $Line.sort_order
        $ProjectID = $Line.project_id
        $ProjectDirectory = $Line.p1Path
        if (!$ProjectID -or !$ProjectDirectory) {
            WriteWarning "Invalid registry line: $Line"
            continue
        }
        # $ProjectDirectory = $ProjectDirectory.Trim()
        if (!(Test-Path -Path $ProjectDirectory)) {
            WriteWarning "Project directory not found: $ProjectDirectory"
            continue
        }
        if ($project_id -and $ProjectID -eq $project_id) {
            return $ProjectDirectory
        }
    }

     WriteWarning "No project found matching project id: $project_id"
     return
}