function Get-Step-List {
    # Statuses:
    # pending       Waiting to run
    # started       Started but not yet finished
    # done          Finished successfully
    # failed        Failed
    # deprecated    No longer run
    
    # TODO: 
    # read this list from a file?
    # add support for "always" and "never" statues
    
    $Steps = @( 
        @{  name="Download-Packages";           priority="mandatory"; status="pending" },
        @{  name="Update-WSL-Kernel";          priority="mandatory"; status="pending" },
        @{  name="Add-Ubuntu-Package";          priority="mandatory"; status="pending" },
        @{  name="Install-WSL";                 priority="mandatory"; status="pending" },
        @{  name="Add-WSL-Users";               priority="mandatory"; status="pending" },
        @{  name="Set-WSL-Passwords";           priority="optional"; status="pending" },
        @{  name="Copy-WSL-Root-Scripts";       priority="mandatory"; status="pending" },
        @{  name="Copy-WSL-User-Scripts";       priority="mandatory"; status="pending" },
        @{  name="InstallWinGet";               priority="mandatory"; status="pending" },
        @{  name="Install-UI-Xaml";             priority="mandatory"; status="pending" },
        @{  name="Install-Keybase";             priority="optional"; status="pending" },
        @{  name="Copy-Keybase-Files";          priority="optional"; status="pending" },
        @{  name="Install-VS-Code";             priority="optional"; status="pending" },
        @{  name="Install-VS-Extensions";       priority="optional"; status="pending" },
        @{  name="Install-Docker";              priority="optional"; status="pending" },
        @{  name="Install-OMZ";                 priority="optional"; status="pending" },
        @{  name="Install-p10k";                priority="optional"; status="pending" },
        @{  name="Set-WSL-User-Env";            priority="optional"; status="pending" },
        @{  name="Get-Git-Repos-WSL";           priority="optional"; status="pending" },
        @{  name="Get-Git-Repos-Win";           priority="optional"; status="pending" },
        @{  name="Install-Node";                priority="optional"; status="pending" },
        @{  name="Update-Windows-Hosts-File";   priority="optional"; status="pending" },
        @{  name="Set-Windows-User-Env";        priority="optional"; status="pending" },
        @{  name="Start-Docker";                priority="optional"; status="pending" },
        @{  name="Install-Build-Tools";         priority="optional"; status="pending" },
        @{  name="Build-Backend";           priority="optional"; status="pending" },
        @{  name="Build-Web";                   priority="optional"; status="pending" },
        @{  name="Start-Backend-Web";           priority="optional"; status="pending" },
        @{  name="Start-Backend-BDD";           priority="optional"; status="pending" },
        @{  name="Start-Web";                   priority="optional"; status="pending" },
        @{  name="Install-Choco";               priority="optional"; status="pending" },
        @{  name="Install-Android-Studio";      priority="optional"; status="pending" },
        @{  name="Install-Android-Tools";       priority="optional"; status="pending" },
        @{  name="Install-Android-SDK";         priority="optional"; status="pending" }
    )
    return $Steps
}
