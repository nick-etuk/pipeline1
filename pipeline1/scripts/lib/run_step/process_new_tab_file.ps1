function process_new_tab_file($task_file) {

    writedebug "Powershell processing new tab file: $task_file"
    # Read file into a variable, delete the file, then process the contents.
    $file_content = Get-Content -Path $task_file -ErrorAction SilentlyContinue
    if (!$file_content) {
        WriteWarn "New tab file $task_file is empty or could not be read."
        return
    }

    # $backup_file = "$task_file.bak"
    # if (Test-Path -Path $backup_file) {
    #     Remove-Item -Path  $backup_file -ErrorAction SilentlyContinue
    # }
    # Copy-Item -Path $task_file -Destination $backup_file -ErrorAction SilentlyContinue
    Remove-Item -Path  $task_file -ErrorAction SilentlyContinue
    
    foreach ($line in $file_content) {
        # $parts = $line -split '~'
        writedebug "Processing line: $line"
        $parts = $line -split ' '
        $script_file = $parts[0]
        writedebug "script_file: $script_file"
        if ($parts.Length -eq 1) {
            $arguments = @()
        } else {
            $arguments = $parts[1..($parts.Length - 1)]
        }
        writedebug "Arguments: $arguments"
        # RunStep -StepID $step_id -Arguments $arguments
        # Assume that init.ps1 has been sourced in terminal_login.ps1
        . "$script_file" -Arguments $arguments
    }
}
