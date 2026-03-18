function parse_template {
    $template_file = "$PSScriptRoot\login_profile_win.template.ps1"
    if (!(Test-Path -Path $template_file -PathType Leaf)) {
        $template_file = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'login_profile_win.template.ps1' -exclude '.venv_p1' -Recurse -File -ErrorAction SilentlyContinue
        if ($template_file -eq $null) { 
            WriteWarn "Could not find login_profile_win.template.ps1 in $P1_ROOT_WIN"
            return
        }
    }

    $template_content = Get-Content -Path $template_file -Raw
    $template_content = $template_content -replace '{{P1_VERSION}}', $P1_VERSION
    $template_content = $template_content -replace '{{P1_ROOT_WIN}}', $P1_ROOT_WIN
    $template_content = $template_content -replace '{{WORKING_DIR}}', $WORKING_DIR

    WriteInfo "Modifying profile $($profile.CurrentUserCurrentHost) with this content from template ${template_file}:"
    WriteInfo $template_content
    return $template_content
}

function edit_login_profile {
    writedebug "=> edit_login_profile"
    if (!(Test-Path -PathType Leaf $profile.CurrentUserCurrentHost)) {
        WriteInfo "Creating `$profile.CurrentUserCurrentHost at $($profile.CurrentUserCurrentHost)"
        New-Item -Path $profile.CurrentUserCurrentHost -ItemType File | Out-Null
    }

    if (Select-String -Path $profile.CurrentUserCurrentHost -Pattern "pipeline1_v$P1_VERSION|workstation1_v$P1_VERSION") {
        WriteDebug "Profile $($profile.CurrentUserCurrentHost) already contains pipeline1 content, skipping modification"
        return
    }

    $profile_content = parse_template

    Add-Content -Path $profile.CurrentUserCurrentHost -Value $profile_content
    Get-Content -Path $profile.CurrentUserCurrentHost | WriteInfo
    $env:PATH += ";$P1_ROOT_WIN"
}
edit_login_profile

