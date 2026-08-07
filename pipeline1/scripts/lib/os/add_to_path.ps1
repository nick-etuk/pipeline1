function Get-Current-Path {
    param(
        [ValidateSet('Machine', 'User', 'Session', 'PS')]
        [string] $Scope = 'User'
    )

    if ($Scope -eq 'Machine') {
        return [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
    }

    if ($Scope -eq 'User') {
        return [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
    }

    # Session/PS scopes do not have a persistent registry value.
    $CurrentPath = $env:Path

    return $CurrentPath
}

function Get-PathEntries {
    param(
        [string] $PathValue
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return @()
    }

    return $PathValue -split ';' | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

function Add-Unique-PathEntry {
    param(
        [string[]] $Entries,
        [string] $Entry
    )

    $NormalizedEntry = $Entry.Trim().TrimEnd('\\')
    if ([string]::IsNullOrWhiteSpace($NormalizedEntry)) {
        return ,$Entries
    }

    foreach ($ExistingEntry in $Entries) {
        if ($ExistingEntry.Trim().TrimEnd('\\').ToLowerInvariant() -eq $NormalizedEntry.ToLowerInvariant()) {
            return ,$Entries
        }
    }

    return @($Entries + $Entry)
}

function Add-To-PowerShell-Path {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path
    )

    $PathToAdd = $Path
    $ProfilePath = $profile.CurrentUserCurrentHost
    $ProfileDirectory = Split-Path -Path $ProfilePath -Parent

    if (-not (Test-Path -Path $ProfileDirectory)) {
        New-Item -Path $ProfileDirectory -ItemType Directory -Force | Out-Null
    }
    
    if (!(Test-Path -PathType Leaf $ProfilePath)) {
        WriteInfo "Creating `$profile.CurrentUserCurrentHost at $ProfilePath"
        New-Item -Path $ProfilePath -ItemType File | Out-Null
    }

    $Banner = 'WriteInfo "*** Profile CurrentUserCurrentHost  ***"'
    $AddScriptsToPathCmd = "`$env:PATH += `";$PathToAdd`""
    # WriteDebug "Adding $AddScriptsToPathCmd to $ProfilePath"

    $CurrentProfile = Get-Content -Path $ProfilePath -Raw
    if ($CurrentProfile -match [regex]::Escape($AddScriptsToPathCmd)) {
        # WriteInfo "Path command already exists in $ProfilePath"
        return
    }

    Add-Content -Path $ProfilePath -Value "`n$Banner`n$AddScriptsToPathCmd`n"
}

function set_android_env_vars {
    if (-not $env:ANDROID_SDK_ROOT) {
        if (-not [string]::IsNullOrWhiteSpace($ANDROID_SDK_ROOT)) {
            $env:ANDROID_SDK_ROOT = $ANDROID_SDK_ROOT
        } elseif (-not [string]::IsNullOrWhiteSpace($env:ANDROID_HOME)) {
            $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
        }
    }

    if (-not $env:ANDROID_HOME -and -not [string]::IsNullOrWhiteSpace($env:ANDROID_SDK_ROOT)) {
        $env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
    }
}

function add_path {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session', 'PS')]
        [string] $Scope = 'User'
    )

    $PathToAdd = $Path.Trim()
    if ([string]::IsNullOrWhiteSpace($PathToAdd)) {
        WriteInfo "Skipping empty path value."
        return
    }

    if (-not (Test-Path -LiteralPath $PathToAdd -PathType Container)) {
        WriteInfo "Skipping missing directory $PathToAdd"
        return
    }

    if ($Scope -eq 'Machine' -or $Scope -eq 'User') {
        $ScopeMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User = [EnvironmentVariableTarget]::User
        }
        $ScopeType = $ScopeMapping[$Scope]

        $CurrentPath = Get-Current-Path -Scope $Scope
        $CurrentEntries = Get-PathEntries -PathValue $CurrentPath
        $NewEntries = Add-Unique-PathEntry -Entries $CurrentEntries -Entry $PathToAdd

        if ($NewEntries.Count -ne $CurrentEntries.Count) {
            write-output "Adding [$PathToAdd] to $Scope path in registry..."
            [Environment]::SetEnvironmentVariable('Path', ($NewEntries -join ';'), $ScopeType)
            WriteInfo "Added $PathToAdd to registry path."
        }
    }

    # The path has been updated in the registry, but the current session may not have the updated path.
    $envPaths = Get-PathEntries -PathValue $env:Path
    $newEnvPaths = Add-Unique-PathEntry -Entries $envPaths -Entry $PathToAdd
    if ($newEnvPaths.Count -ne $envPaths.Count) {
        $env:Path = $newEnvPaths -join ';'
        WriteInfo "Added $PathToAdd to current session path."
    }
}

function set_java_home {
    if (-not $env:JAVA_HOME) {
        if ("CPC-NIET2-AY8UE DESKTOP-2022".Contains($env:ComputerName)) { 
            $env:JAVA_HOME = 'C:\Program Files\Amazon Corretto\jdk17.0.12_7'
        }
        else {
            $env:JAVA_HOME = 'C:\app\Android Studio\jbr'
        }
    }
}
function add_to_path {
    set_android_env_vars
    set_java_home
    add_path -path "$env:JAVA_HOME\bin"
    add_path -path "$P1_ROOT_SCRIPT"
    add_path -path "$env:ANDROID_SDK_ROOT\emulator"
    add_path -path "$env:ANDROID_SDK_ROOT\platform-tools"
}
