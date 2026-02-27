function Get-Elevated-Steps {
    $global:ElevatedSteps = @(
        "Update-Windows-Hosts-File"
        "Install-Choco"
        "Install-Android-Studio"
        "Install-Android-Tools"
        "Add-Defender-Exclusions"
    )
}
