function Find-GCM-Executable {
    $CachedPath = Get-Config 'file_paths' 'git-credential-manager.exe'
    if ($CachedPath) {
        WriteDebug "Git Credential Manager found in cache: $CachedPath"
        return $CachedPath
    }

    $GitPath = (Get-Command git).path
    $BasePath = $GitPath -replace "\\bin\\git.exe",""
    $BasePath = $BasePath -replace "\\cmd\\git.exe",""
    WriteDebug "Git base path:$BasePath"

    $ExpectedPaths = @(
        "$BasePath\mingw64\bin\git-credential-manager.exe",
        "$BasePath\mingw64\libexec\git-core\git-credential-manager.exe",
        "$BasePath\mingw64\libexec\git-core\git-credential-manager-core.exe"
        )
    
    foreach ($Path in $ExpectedPaths) {
        if (Test-Path -PathType Leaf $Path) {
            WriteDebug "Found GCM at expected path $Path"
            Set-Config 'git-credential-manager.exe' $Path  'file_paths'
            return $Path
        }
    }

    WriteInfo "Searching for Git Credential Manager..."
    $Result = Find-Executable -FileName 'git-credential-manager.exe' -InDirectory "C:\Program Files"
    # $Result = Get-Childitem -Path "C:\Program Files" -Include "git-credential-manager.exe" -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName

    if ($Result) { return $Result.FullName }

    $Found = $false
    while (!$Found) {
        WriteInfo "Git credential manager not found. Please install it,"
        WriteInfo "and then enter the path to its executable here:"
        $Path = Read-Host "Git credential manager path"
        $found = Test-Path -PathType Leaf $Path
    }
    return $Path
}

function Get-Config-New {
    # todo: implement this
    param (
        $Parameter
    )
    Get-Content $CONFIG_FILE | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
    # return ($h.Get_Item($Parameter)).*
}
