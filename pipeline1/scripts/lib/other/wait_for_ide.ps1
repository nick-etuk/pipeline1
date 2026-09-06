function wait_for_ide($IDE) {
    # Some IDEs can take a while to start up, so wait a maximum of 30 seconds for the IDE to start up.
    $max_wait = 30
    $waited = 0

    switch ($IDE) {
        android_studio {
            $exe_filename = 'studio64.exe'
        }
        intellij {
            $exe_filename = 'idea64.exe'
        }
        vscode {
            $exe_filename = 'code.exe'
        }
        default {
            WriteWarn "Unknown IDE: $IDE"
            return
        }
    }

    while ($true) {
        $ide_processes = Get-Process | Where-Object { $_.MainWindowTitle -ne '' } | Where-Object { $_.Path -like "*$exe_filename*" }
        if ($ide_processes) {
            Write-Output "IDE started successfully."
            break
        }
        Start-Sleep -Seconds 1
        $waited += 1
        if ($waited -ge $max_wait) {
            WriteWarn "IDE did not start within $max_wait seconds."
            break
        }
    }
}
