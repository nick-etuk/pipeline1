function Get-Current-Path {
    param(
        [ValidateSet('Machine', 'User', 'Session' , 'PS')]
        [string] $Scope = 'User'
    )

    # $ScopeMapping = @{
    #     Machine = [EnvironmentVariableTarget]::Machine
    #     User = [EnvironmentVariableTarget]::User
    # }

    # $ScopeType = $ScopeMapping[$Scope]
    # $CurrentPath = [Environment]::GetEnvironmentVariable('Path', $ScopeType) -split ';'
    $CurrentPath = (get-item "HKCU:\Environment").GetValue("Path", $null, 'DoNotExpandEnvironmentNames')

    return $CurrentPath
}

function Add-To-PowerShell-Path {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path
    )

    $PathToAdd = $Path
    
    if (!(Test-Path -PathType Leaf $profile.CurrentUserCurrentHost)) {
        WriteInfo "Creating `$profile.CurrentUserCurrentHost at $($profile.CurrentUserCurrentHost)"
        New-Item -Path $profile.CurrentUserCurrentHost -ItemType File | Out-Null
    }

    $Banner = 'WriteInfo "*** Profile CurrentUserCurrentHost  ***"'
    $AddScriptsToPathCmd = "`$env:PATH += `";$PathToAdd`""
    WriteDebug "Adding [$AddScriptsToPathCmd] to $($profile.CurrentUserCurrentHost)"

    Add-Content -Path $profile.CurrentUserCurrentHost -Value "`n$Banner`n$AddScriptsToPathCmd`n"
}

function Add-To-Path {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session' , 'PS')]
        [string] $Scope = 'User'
    )

    $PathToAdd = $Path
    
    if ($Scope -ne 'Session') {
        $ScopeMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User = [EnvironmentVariableTarget]::User
        }
        $ScopeType = $ScopeMapping[$Scope]

        $CurrentPath = Get-Current-Path -Scope $Scope

        if ($CurrentPath -notcontains $PathToAdd) {
            $CurrentPath = "$CurrentPath;$PathToAdd" | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', $CurrentPath -join ';', $ScopeType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $PathToAdd) {
        $envPaths = "$envPaths;$PathToAdd" | Where-Object { $_ }
        $env:Path = $envPaths -join ';'
    }

    # $NewPath = "$CurrentPath;$PathToAdd"
    # Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $NewPath
    # return $Result
}
