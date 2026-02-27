function save_directories {
    # $profileContent = Get-Content -Path $profile.CurrentUserCurrentHost -ErrorAction SilentlyContinue
    # $profileContent = $profileContent -replace "`$global:P1_ROOT_WIN = '$OldRootPath'", "`$global:P1_ROOT_WIN = '$P1_ROOT_WIN'"
    # Set-Content -Path $profile.CurrentUserCurrentHost -Value $profileContent -ErrorAction SilentlyContinue
    Set-Config p1_root_win $P1_ROOT_WIN
    $Script:REPO_DIR = (get-item $P1_ROOT_WIN).parent.FullName
    Set-Config repo_dir $REPO_DIR
}

function set_repo_dir {
    # Checks if P1_ROOT_WIN has changed. Update REPO_DIR and the profile if it has.

    $OldRootPath = Get-Config p1_root_win
    if (-not $OldRootPath) {
        save_directories
        return
    }
    
    if ($OldRootPath -ne $P1_ROOT_WIN) {
        WriteWarning "Pipeline1 root path has changed from $OldRootPath to $P1_ROOT_WIN"
        WriteWarning "Updating $profile.CurrentUserCurrentHost"
        save_directories
    }
}