function create_venv($project_id) {
    # if the project is p1, use any existing venv.
    # only create a venv for p1 if no venv exists.
    # for other projects, create and use their own venvs.

    if ($project_id -eq "p1" -and $env:VIRTUAL_ENV) {
        # Write-output "Virtual environment already active. Using $env:VIRTUAL_ENV"
        return
    }

    $project_root = (get_project $project_id).sourceCodePath
    
    Write-Error "create_venv should not be called for project $project_id"
    return
    $activation_file = Get-Childitem -Path "$project_root" -Include 'Activate.ps1' -File -Recurse -ErrorAction SilentlyContinue
    if ($activation_file) {
        Write-output "Virtual environment already exists for $project_id at $($activation_file.DirectoryName)"
        return
    }

    Write-output "Virtual environment not found for $project_id. Create venv? (y/n)"
    $prompt = Read-Host
    if ($prompt -eq "y") {
        Write-output "Creating virtual environment..."
        $venv_dir = "$project_root\.venv_$project_id"
        python -m venv "$venv_dir"
    }
}
