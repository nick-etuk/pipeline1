function OneDriveReady {
	if (!$env:OneDrive) { return $false }

	if(!(Test-Path -PathType Container $env:OneDrive)) { return $false }
      	
	return $true
}
