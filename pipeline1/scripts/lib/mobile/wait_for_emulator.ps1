function wait_for_emulator_android {
    while ($true) {
        $output = adb shell getprop sys.boot_completed 2>&1
        if ($output -match "1") {
            break
        }
        Start-Sleep -Seconds 1
    }
}
