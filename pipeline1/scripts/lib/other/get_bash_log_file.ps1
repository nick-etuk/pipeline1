function Get-Bash-Log-File {
    Param (
        [Parameter(Mandatory=$true)]
        [string]
        $CurrentLogFile
    )

    if ($CurrentLogFile.gettype().Name -eq "Object[]"){ 
        $Result = $CurrentLogFile[1]
    } else {
        $Result = $CurrentLogFile
    }

    $Result = $Result -replace "\.log", ".bash.log"
    $Result = $Result -replace "C:", "\mnt\c"
    WriteInfo "bash log file:$Result"
    # if (!(Test-Path -PathType Leaf $Result)) {
    #     New-Item -Path $Result -ItemType File
    # }

    return $Result
}
