function daily_tasks() {
    $flag="$WORKING_DIR/context/global/daily_tasks.txt"
    if (Test-Path -Path $flag -PathType Leaf) {
        $last_update = Get-Content -Path $flag
        if ((Get-Date $last_update) -ge (Get-Date).AddDays(-1)) {
            Write-Output "Daily tasks done today ($(Get-Date $last_update -Format 'dddd dd MMMM yyyy at HH:mm'))"
            return
        }
    }
    check_for_os_updates
    update_remote_steps

    Get-Date -Format "yyyy-MM-ddTHH:mm:ss" | Out-File -FilePath $flag -Encoding ascii
}
