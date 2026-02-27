$taskName = "FirstLogin"
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($null -eq $task) { exit 0 }

Write-Output "Unscheduling $taskName"
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
