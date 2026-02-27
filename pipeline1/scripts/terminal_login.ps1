Set-StrictMode -Version 3.0

if ($env:TERM_PROGRAM -and $env:TERM_PROGRAM -ne 'Windows Terminal') {
    exit 0
}

$init_script = Get-Childitem -Path "$P1_ROOT_WIN" -Include 'init.ps1' -Recurse
if (-not $init_script) {
    Write-Error "init.ps1 not found in $P1_ROOT_WIN. Aborting."
}

$Script:P1_ROOT_SCRIPT = $init_script.Directory

$new_tab_queue="$HOME/.pipeline1/working/new_tab_queue"
if(Test-Path -PathType Container -Path $new_tab_queue) {
    $files = Get-ChildItem -Path $new_tab_queue
    $file_count = ($files | Measure-Object).Count
    if ($file_count -gt 0) {
        Write-Output "Tasks found in New Tab queue..."
        . $P1_ROOT_SCRIPT/init.ps1
        $oldest_file = $files | Sort-Object LastWriteTime | Select-Object -First 1
        process_new_tab_file $oldest_file.FullName
        return
    }
}

$StartupScript = "$P1_ROOT_WIN/p1.ps1"
. $StartupScript
# . $($StartupScript.FullName)

$default_step_path=$(Get-Config 'default_step_path')
if ($default_step_path -and (Test-Path -Path $default_step_path -PathType Container)) {
    Set-Location -Path $default_step_path
}
