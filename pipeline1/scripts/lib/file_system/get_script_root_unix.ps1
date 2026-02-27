function Get-ScriptRootUnix {
    if (Test-Path variable:Script:P1_ROOT_UNIX) { 
        if (!([string]::IsNullOrEmpty($Script:P1_ROOT_UNIX))) {
            return 
        }
    }
    
    $Script:P1_ROOT_UNIX = Get-Config 'P1_ROOT_UNIX'
    if ($Script:P1_ROOT_UNIX) { 
        return 
    }
    
    WriteInfo "Searching for pipeline1 in WSL"
    $Script:P1_ROOT_UNIX = $(wsl -u $P1_USER_UNIX find ~ -type d -name 'pipeline1')

    if ($Script:P1_ROOT_UNIX) {
        Set-Config 'P1_ROOT_UNIX' $Script:P1_ROOT_UNIX
        return
    }
    WriteInfo "Cannot find pipeline1 directory in WSL"
}
