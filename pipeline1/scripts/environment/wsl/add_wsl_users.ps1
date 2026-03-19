function Add-WSL-Users {

    Write-Output "[boot]`nsystemd=true`n[user]`ndefault=$P1_USER_UNIX`n" > $WORKING_DIR\wsl.conf
    $UnixPath = Get-Unix-Path "$WORKING_DIR\wsl.conf"
    writedebug "Config file from Unix: $UnixPath"
    wsl -u root cp $UnixPath /etc

    wsl -u root groupadd $P1_USER_UNIX
    wsl -u root groupadd docker
    wsl -u root useradd -m -g $P1_USER_UNIX -s /bin/bash -G docker,sudo $P1_USER_UNIX

    $Cmd = "`$(echo $P1_USER_UNIX | openssl passwd -6 -stdin)"
    wsl -u root usermod --password $Cmd $P1_USER_UNIX

    wsl -u $P1_USER_UNIX touch ~/.hushlogin

    # Save user names to a file. Read by config_base.sh.
    Write-Output "P1_USER_UNIX='$P1_USER_UNIX'" > $WORKING_DIR\P1_USER_UNIXnames.sh
    Write-Output "P1_USER_WIN='$P1_USER_WIN'" >> $WORKING_DIR\P1_USER_UNIXnames.sh
    Write-Output "WORKING_DIR_WIN='$(Get-Unix-Path $WORKING_DIR)'" >> $WORKING_DIR\P1_USER_UNIXnames.sh

    $UnixPath = Get-Unix-Path "$WORKING_DIR\P1_USER_UNIXnames.sh"
    wsl -u $P1_USER_UNIX cp $UnixPath ~/.pipeline1/working

}
Add-WSL-Users