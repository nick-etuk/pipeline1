#!/usr/bin/env bash

configure_git_credential_manager() {
    local gcm_path_win
    local gcm_path_unix
    
    [ git config --global --list | grep -iq 'git-credential-manager' ] && return 0
    
    gcm_path_win='F:\app\Git\mingw64\bin\git-credential-manager.exe'
    # gcm_path_win='C:\Program Files\Git\mingw64\bin\git-credential-manager.exe'
    
    gcm_path_unix=$(wslpath "$gcm_path_win")

    git config --global credential.helper \""$gcm_path_unix"\"
    # git config --global credential.helper "/mnt/f/app/Git/mingw64/bin/git-credential-manager.exe"
    # git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
    
    # git config --global user.email "nick_etuk@hotmail.com"
    # git config --global user.name "Nick Etuk"
}
