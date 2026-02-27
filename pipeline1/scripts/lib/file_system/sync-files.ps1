function Sync-File-WSL {
    param (
        [Parameter(Mandatory, Position=0)]
        [IO.FileInfo]$SourceFile,
        [Parameter(Mandatory, Position=1)]
        [IO.FileInfo]$DestFile
    )

    # WriteDebug "=>Sync-Files-WSL"
    # $SourceFile | Get-Member
    # $DestFile | Get-Member
    
    # WriteDebug "LastWriteTime:"
    # $SourceFile.LastWriteTime
    # $DestFile.LastWriteTime

    # WriteInfo "Skipping existing WSL file $($SourceFile.FullName)"
    # todo: implement this
}

function Sync-Files {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        $Source,
        [Parameter(Position=1, Mandatory=$true)]
        $Destination
    )

    # WriteDebug "=>Sync-Files"
    if ($Source -eq $Destination) {
        WriteWarning "Source and destination are the same"
        return
    }
    
    if (!(Test-Path -PathType Leaf "~\sync-ps.ps1") -and (Test-Path -PathType Leaf "$SCRIPT_DIR_REPO\sync-ps.ps1")) {
        Copy-Item "$SCRIPT_DIR_REPO\sync-ps.ps1" -Destination ~
    }
    
    if (!(Test-Path -PathType Container $Source)) {
        WriteWarning "Source directory $Source not found"
        return
    }
    
    if (!(Test-Path -PathType Container $Destination)) {
        New-Item -Path $Destination -ItemType Directory | Out-Null
    }

    # Get-ChildItem $Source -File -Recurse | Where-Object LastWriteTime -gt (Get-Date).AddMinutes(-5) | ForEach-Object {
    Get-ChildItem $Source -File -Recurse | ForEach-Object {
        $SourceFile = [IO.FileInfo]$_
        $SourceFileName = $SourceFile.FullName
        # WriteDebug "Source file: $SourceFileName"
        
        $DestFile = [IO.FileInfo]$_.FullName.Replace($Source, $Destination)
        $DestFileName = $DestFile.FullName
        # WriteDebug "Destination file: $DestFileName"

        if (!(Test-Path -PathType Leaf $DestFileName)) {
            WriteInfo "Added $DestFileName"
            $destFile.Directory.Create()
            # Copy-Item -LiteralPath $_.FullName -Destination $DestFile.FullName -PassThru | Out-Null
            Copy-Item -LiteralPath $_.FullName -Destination $DestFileName -PassThru | Out-Null
            return
        }

        if ($SourceFileName.contains("//wsl") -or $SourceFileName.contains("\\wsl")) {
            Sync-File-WSL  $SourceFile $DestFile
            return
        }

        if($_.LastWriteTime -eq $DestFile.LastWriteTime) { return }

        WriteInfo "Updated $DestFileName"
        $DestFile.Directory.Create()
        Copy-Item -LiteralPath $_.FullName -Destination $DestFileName -PassThru | Out-Null
    }
}
