Write-Output "$P1_USER_UNIX ALL=(ALL) NOPASSWD: ALL" > $WORKING_DIR\90-sudo-nopasswd
$UnixPath = Get-Unix-Path "$WORKING_DIR\90-sudo-nopasswd"
wsl -u root cp $UnixPath /etc/sudoers.d
wsl -u root chmod 0440 /etc/sudoers.d/90-sudo-nopasswd
