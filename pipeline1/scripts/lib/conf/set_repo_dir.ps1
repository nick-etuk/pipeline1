function save_directories {
    # $profileContent = Get-Content -Path $profile.CurrentUserCurrentHost -ErrorAction SilentlyContinue
    # $profileContent = $profileContent -replace "`$global:P1_ROOT_WIN = '$OldRootPath'", "`$global:P1_ROOT_WIN = '$P1_ROOT_WIN'"
    # Set-Content -Path $profile.CurrentUserCurrentHost -Value $profileContent -ErrorAction SilentlyContinue
    set_context p1_root_win $P1_ROOT_WIN
    $Global:REPO_DIR = (get-item $P1_ROOT_WIN).parent.FullName
    set_context repo_dir $Global:REPO_DIR
}

function set_repo_dir {
    # Check if P1_ROOT_WIN has changed. Update REPO_DIR and the profile if it has.

    $OldRootPath = get_context p1_root_win
    if (-not $OldRootPath) {
        save_directories
        return
    }
    
    if ($OldRootPath -ne $P1_ROOT_WIN) {
        WriteWarning "Pipeline1 root path has changed from $OldRootPath to $P1_ROOT_WIN"
        WriteWarning "Updating $profile.CurrentUserCurrentHost"
        save_directories
        return
    }

    if (Test-Path variable:Global:REPO_DIR) {
        write-Output "REPO_DIR is already set to $Global:REPO_DIR"
    } else {
        $Global:REPO_DIR = get_context repo_dir
     }

}