function IsDistroInstalled ([parameter(Mandatory=$true)] $Distro) {
    writedebug "=>IsDistroInstalled $Distro"
    $Distros = wsl -l -q
    $Found = $false;
    foreach ($d in $Distros) {
        $utf8 = $d -replace [char]0
        if ($utf8 -match $Distro) {
            $Found=$true
            break
        }
    }
    return $Found
}