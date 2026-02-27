function Search-For-Exe {
    param (
        $FileName,
        $InDirectory
    )

    $LikelyPaths = @(
        "C:\Program Files",
        "$env:LocalAppData\Programs",
        "$env:LocalAppData"
        )
    
    foreach ($Path in $LikelyPaths) {
        $Result = Get-Childitem -Path $Path -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
        if ($Result) { 
            WriteDebug "$FileName found in likely path $Path"
            $CorrectDirectory = CheckDirectory $Result.FullName $Path $InDirectory
            if ($CorrectDirectory) { return $CorrectDirectory }
        }
    }

    foreach ($Path in $env:Path) {
        $Result = Get-Childitem -Path $Path -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
        if ($Result) { 
            WriteDebug "$FileName found in environment path $Path"
            $CorrectDirectory = CheckDirectory $Result.FullName $Path $InDirectory
            if ($CorrectDirectory) { return $CorrectDirectory }
        }
    }

    WriteInfo "Searching C drive for $FileName..."
    $Result = Get-Childitem -Path "C:\" -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
    if ($Result) { 
        $CorrectDirectory = CheckDirectory $Result.FullName $Path $InDirectory
        if ($CorrectDirectory) { return $CorrectDirectory }
    }
}

function CheckDirectory {
    param (
        [Parameter(Position=0)]
        $FileName,
        [Parameter(Position=1)]
        $Path,
        [Parameter(Position=2)]
        $InDirectory
    )
    if (!($InDirectory)) {
        WriteInfo "$FileName found at $Path"
        return $Path
    }

    if($Path -match $InDirectory) {
        WriteInfo "$FileName in $InDirectory found at $Path"
        return $Path
    }
    WriteInfo "$FileName found, but not in expected directory $InDirectory. Path found is $Path"
}

function Find-Executable {
    param (
        $FileName,
        $InDirectory
    )

    $CachedPath = Get-Config $FileName 'file_paths'
    if ($CachedPath) {
        WriteDebug "$FileName found in cache"
        return $CachedPath
    }

    $Result = (Get-Command $FileName -errorAction SilentlyContinue).path
    if ($Result) { 
        WriteInfo "$FileName is a command"
        $CorrectDirectory = CheckDirectory $FileName $Result $InDirectory 
        if ($CorrectDirectory) { 
            Set-Config 'git-credential-manager.exe' $CorrectDirectory 'file_paths'
            return $CorrectDirectory }
    }

    $Result = Search-For-Exe $FileName
    if ($Result) { 
        $CorrectDirectory = CheckDirectory $FileName $Result $InDirectory
        if ($CorrectDirectory) { 
            Set-Config $FileName $CorrectDirectory  'file_paths'
            return $CorrectDirectory
        }
    }
}
