function Assert-App-Installed {
    param (
        $AppName
    )

    $Collection = Get-WmiObject -Class Win32_Product | sort-object Name | Select-Object Name | Where-Object { $_.Name -eq $AppName }

    $Result = $false
    $Collection.foreach({
        if ($_.Name -eq $AppName) {
            $Result = $true
            return
        }
    })
   
    return $Result
}