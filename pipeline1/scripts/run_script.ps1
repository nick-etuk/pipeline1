param (
    [Parameter(Position=0)]
    [string]$script_file,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$step_args
)

# Don't put this script into the lib directory because it is a script, not a function.

$ErrorActionPreference = "Stop"

. $PSScriptRoot\init.ps1

write-output "run_step_script.ps1 running $script_file with args: $step_args"
. $script_file -Arguments $step_args


$default_step_path=$(Get-Config 'default_step_path')
if ($default_step_path -and (Test-Path -Path $default_step_path -PathType Container)) {
    Set-Location -Path $default_step_path
}
