function pip_install($project_id) {
        if ($project_id -ne "p1") {
        WriteWarn "pip_install not yet implemented for projects other than p1."
        return
    }
    
    if ($project_id -eq "p1") {
        $package_name = "pipeline1"
        $project_root = "$P1_ROOT_WIN"
    } else {
        $package_name = $project_id
    }

    if (!(pip list | Select-String -Pattern $package_name)) {
        python -m pip install --upgrade pip
        WriteInfo "Installing $package_name packages..."
        pip install -r "$project_root/requirements.txt" # todo: fix this
        WriteInfo "Installing $package_name as an editable package at $project_root..."
        pip install -e $project_root
    }
}
