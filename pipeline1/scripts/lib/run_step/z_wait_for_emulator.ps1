function IsRunning {
    if (adb -s emulator-$ANDROID_EMULATOR_PORT shell echo 'I am alive' | Select-String -Pattern 'I am alive') {
        return $true
    }
    return $false
}

function Wait-For-Emulator {
    $WaitTime = 0
    $MaxWaitTime = 60
    WriteInfo -NoNewline "`nWaiting for emulator "
    while (!(IsRunning) -or ($WaitTime -gt $MaxWaitTime)) {
        WriteInfo -NoNewline "."
        Start-Sleep -Seconds 3
        $WaitTime += 3

    }
    
    if ($WaitTime -gt $MaxWaitTime) {
        WriteInfo "`n"
        WriteInfo "Emulator not started after $MaxWaitTime seconds."
        break
    }
    WriteInfo "`n"    
}
