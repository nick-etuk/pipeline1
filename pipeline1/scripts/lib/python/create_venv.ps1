function create_venv($project_id) {
    if ($project_id -ne "p1") {
        WriteWarn "create_venv not yet implemented for projects other than p1."
        return
    }

    $venv_dir = "$P1_ROOT_WIN\.venv_p1"
    if (Test-Path -PathType Container -Path $venv_dir) {
        return
    }

    Write-output "Create Python virtual environment for $project_id ? (y/n)"
    $prompt = Read-Host
    if ($prompt.ToLower() -eq "y") {
        Write-output "Creating virtual environment..."
        python -m venv "$venv_dir"
    }

}
