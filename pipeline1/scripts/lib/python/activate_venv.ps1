function activate_venv($project_id) {
    if ($env:VIRTUAL_ENV) {
        if ($env:VIRTUAL_ENV -like "*$project_id*") {
            WriteInfo "Virtual environment for $project_id is already active."
            return
        }
        if (get-command deactivate -ErrorAction SilentlyContinue) {
            WriteInfo "Deactivating current virtual environment..."
            deactivate
        } else {
            WriteWarn "No deactivate command found. Please deactivate the current virtual environment manually."
            return
        }
    }

    WriteInfo "Activating virtual environment for $project_id..."
    $project_root = (get_project $project_id).sourceCodePath

    $activate_script = Get-Childitem -Path "$project_root" -include 'Activate.ps1' -Recurse
    if (-not $activate_script) {
        WriteWarn "Activate.ps1 not found. Aborting."
        return
    }
    WriteDebug "activate_script: $activate_script"
    & $($activate_script.FullName)
}