function Invoke-Refresh-Path {
    $env:Path = Get-Current-Path -Scope User
}