function Get-Unix-Path ([Parameter(Mandatory=$true)] $Path) {

    $UnixPath = $Path.ToLower() -replace "\\", "/"
    $UnixPath = $UnixPath -replace " ", "\ "
    $UnixPath = $UnixPath -replace ":", ""
    $UnixPath = "/mnt/$UnixPath"

    return $UnixPath
}