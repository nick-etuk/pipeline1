function start_emulator {
    $platform = $args[0]
    $mode = $args[1]

    # No need to support ios emulator in Windows
    
    # Start-Process pwsh -ArgumentList "-NoExit", "-c", "`$Host.UI.RawUI.BackgroundColor = 'DarkBlue'; Clear-Host; $PSScriptroot\start_emulator.ps1"
    switch ($mode) {
        'writable' {
            emulator -avd $ANDROID_DEFAULT_DEVICE -no-snapshot-load -writable-system
        }
        default {
            emulator -avd $ANDROID_DEFAULT_DEVICE
            wait_for_emulator_android
            adb reverse tcp:3100 tcp:3100
        }
    }
}
