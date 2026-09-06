function Search-For-Exe {
    param (
        $FileName,
        $ExpectedDirectory
    )

    $VSCodePath = (Get-Command code).path
    $VSCodeRoot = $VSCodePath -replace "\\bin\\code.cmd",""
    $VSCodeParent = Split-Path -Path $VSCodeRoot -Parent
    writeDebug "VSCodeParent: $VSCodeParent"

    $LikelyPaths = @(
        "$VSCodeParent",
        "C:\Program Files",
        "$env:LocalAppData\Programs",
        "$env:LocalAppData"
        )
    
    foreach ($Path in $LikelyPaths) {
        WriteInfo "Searching likely path $Path for $FileName in find-executable.ps1 ..."
        $Result = Get-Childitem -Path $Path -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
        if ($Result) { 
            WriteDebug "$FileName found in likely path $Path"
            $CorrectDirectory = CheckDirectory $Result.FullName $Path $ExpectedDirectory
            if ($CorrectDirectory) { return $CorrectDirectory }
        }
    }

    foreach ($Path in $env:Path) {
        WriteInfo "Searching env:Path $Path for $FileName in find-executable.ps1 ..."
        $Result = Get-Childitem -Path $Path -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
        if ($Result) { 
            WriteDebug "$FileName found in environment path $Path"
            $CorrectDirectory = CheckDirectory $Result.FullName $Path $ExpectedDirectory
            if ($CorrectDirectory) { return $CorrectDirectory }
        }
    }

    WriteInfo "Searching C drive for $FileName..."
    $Result = Get-Childitem -Path "C:\" -Include $FileName -File -Recurse -ErrorAction SilentlyContinue | Select-Object FullName
    if ($Result) { 
        $CorrectDirectory = CheckDirectory $Result.FullName $Path $ExpectedDirectory
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
        $ExpectedDirectory
    )
    if (!($ExpectedDirectory)) {
        WriteInfo "$FileName found at $Path"
        return $Path
    }

    if($Path -match $ExpectedDirectory) {
        WriteInfo "$FileName in $ExpectedDirectory found at $Path"
        return $Path
    }
    WriteInfo "$FileName found, but not in expected directory $ExpectedDirectory. Path found is $Path"
}

function Find-Executable {
    param (
        $FileName,
        $ExpectedDirectory
    )
    $CachedPath = get_context $FileName 'file_paths'
    if ($CachedPath) {
        WriteDebug "$FileName found in cache"
        return $CachedPath
    }

    $Result = (Get-Command $FileName -errorAction SilentlyContinue).path
    if ($Result) { 
        WriteInfo "$FileName is a command"
        
        if (!($ExpectedDirectory)) {
            set_context $FileName $Result 'file_paths'
            return $Result
        }

        $CorrectDirectory = CheckDirectory $FileName $Result $ExpectedDirectory 
        if ($CorrectDirectory) { 
            set_context $FileName $CorrectDirectory 'file_paths'
            return $CorrectDirectory 
        }
    }

    $Result = Search-For-Exe $FileName
    if ($Result) { 
        $CorrectDirectory = CheckDirectory $FileName $Result $ExpectedDirectory
        if ($CorrectDirectory) { 
            set_context $FileName $CorrectDirectory  'file_paths'
            return $CorrectDirectory
        }
    }
}
