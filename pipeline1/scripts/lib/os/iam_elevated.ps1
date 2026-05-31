function IamElevated {
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    if ($myWindowsPrincipal.IsInRole($adminRole)) { return $true }

    return $false
}