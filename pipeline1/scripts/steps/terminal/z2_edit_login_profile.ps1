function edit_login_profile {
    writedebug "=> edit_login_profile"
    if (!(Test-Path -PathType Leaf $profile.CurrentUserCurrentHost)) {
        Write-Output "Creating `$profile.CurrentUserCurrentHost at $($profile.CurrentUserCurrentHost)"
        New-Item -Path $profile.CurrentUserCurrentHost -ItemType File | Out-Null
    }
    # return early if profile already contains pipeline1 or workstation1 content
    if (Select-String -Path $profile.CurrentUserCurrentHost -Pattern "pipeline1_v$P1_VERSION|workstation1_v$P1_VERSION") {
        Write-Output "Profile $($profile.CurrentUserCurrentHost) already contains pipeline1 content, skipping modification"
        return
    }

    $StartBanner = "# pipeline1_v$P1_VERSION start"
    $Line1 = "`$global:WORKING_DIR = `"$HOME\.pipeline1\working`""
    $Line2 = "`$ConfigFile = `"$WORKING_DIR\context\general\p1_root_win.txt`""
    $Line3 = "if (!(Test-Path `"$WORKING_DIR\context\general`" -PathType Container)) {"
    $Line4 = "    write-output `"Pipeline1 dynamic config directory not found at `$WORKING_DIR\context\general`""
    $Line5 = '    exit 0'
    $Line6 = '}'
    $Line7 = "if (!(Test-Path `$ConfigFile)) {"
    $Line8 = "    write-output `"$ConfigFile not found`""
    $Line9 = "    exit 0"
    $Line10 = "}"
    $Line11 = "`$global:P1_ROOT_WIN = (Get-Content `$ConfigFile).Trim()"
    $Line12 = "write-output `"Pipeline1 root set to `$P1_ROOT_WIN`""
    $Line13 = "`$env:PATH += ';$P1_ROOT_WIN'"
    $Line14 = "if (`$env:TERM_PROGRAM -and `$env:TERM_PROGRAM -ne 'Windows Terminal') { exit 0 }"
    $Line15 = "`$WorkstationStartup = Get-Childitem -Path `$P1_ROOT_WIN -Include 'p1.ps1' -File -Recurse -ErrorAction SilentlyContinue"
    $Line16 = "if (`$null -eq `$WorkstationStartup) {"
    $Line17 = "    Write-Output `"Could not find Pipeline1 startup script p1.ps1 in `$P1_ROOT_WIN`""
    $Line18 = '    exit 0'
    $Line19 = '}'
    $Line20 = "& `$(`$WorkstationStartup.FullName)"
    $EndBanner = "# pipeline1_v$P1_VERSION end"

    $AdditionalContent = "$StartBanner`n$Line1`n$Line2`n$Line3`n$Line4`n$Line5`n$Line6`n$Line7`n$Line8`n$Line9`n$Line10`n$Line11`n$Line12`n$Line13`n$Line14`n$Line15`n$Line16`n$Line17`n$Line18`n$Line19`n$Line20`n$EndBanner`n"
    WriteDebug "Modifying profile $($profile.CurrentUserCurrentHost)"
    # WriteDebug $AdditionalContent

    Add-Content -Path $profile.CurrentUserCurrentHost -Value $AdditionalContent
    Get-Content -Path $profile.CurrentUserCurrentHost
    $env:PATH += ";$P1_ROOT_WIN"
}
edit_login_profile
