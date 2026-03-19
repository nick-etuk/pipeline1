function install_ui_xaml {

    if (!(Invoke-Step-Entry)) { return }

    try{
        $MsUiXaml = "$env:TEMP\$([System.IO.Path]::GetRandomFileName())-Microsoft.UI.Xaml.2.8.6"
        $MsUiXamlZip = "$($MsUiXaml).zip"
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.8.6" -OutFile $MsUiXamlZip
        Expand-Archive $MsUiXamlZip -DestinationPath $MsUiXaml
        Add-AppxPackage -Path "$($MsUiXaml)\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.8.appx" -ForceApplicationShutdown
        Write-Output "Done Installing Microsoft.UI.Xaml"
    } catch {
        Write-Error "Failed to install Microsoft.UI.Xaml"
        Write-Error $_
    }
    
    Invoke-Step-Exit
}