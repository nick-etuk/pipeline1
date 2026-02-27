function Get-Process-By-Port {
    param (
        [int]$Port
    )

    Get-NetTCPConnection | Where-Object {$_.LocalPort -eq $Port -and $_.State -eq 'Listen'} |
    ForEach-Object {
        $ProcessName = (Get-Process -Id $_.OwningProcess).ProcessName
        [PSCustomObject]@{
            LocalAddress = $_.LocalAddress
            LocalPort = $_.LocalPort
            OwningProcess = $_.OwningProcess
            ProcessName = $ProcessName
        }
    }
}