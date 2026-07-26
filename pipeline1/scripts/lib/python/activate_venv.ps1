function activate_venv($project_id) {
    if ($project_id -ne "p1") {
        WriteWarn "activate_venv not yet implemented for projects other than p1."
        return
    }

    if ($env:VIRTUAL_ENV) {
        if ($env:VIRTUAL_ENV -like "*$project_id*") {
            # WriteInfo "Virtual environment for $project_id is already active."
            return
        }

        # todo: is it necessary to deactivate the venv if the statement above
        # shows that there isn't one active? No, but it is possible that the user has activated a different venv, so we should deactivate it first.
        # if (get-command deactivate -ErrorAction SilentlyContinue) {
        #     WriteInfo "Deactivating current virtual environment..."
        #     deactivate
        # } else {
        #     WriteWarn "No deactivate command found. Please deactivate the current virtual environment manually."
        #     return
        # }
    }

    WriteInfo "Activating virtual environment for $project_id..."

    $activate_script = Get-Childitem -Path "$P1_ROOT_WIN\.venv_p1" -include 'Activate.ps1' -Recurse
    if (-not $activate_script) {
        WriteWarn "Activate.ps1 not found. Aborting."
        return
    }

    & $($activate_script.FullName)
}