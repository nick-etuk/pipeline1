function install_pyenv {
    if (Get-Command pyenv -ErrorAction SilentlyContinue) { return }

    $python_command = Get-Command python -ErrorAction SilentlyContinue
    if ($python_command) {
        $python_version = $python_command.FileVersionInfo.ProductVersion.Split(".")
        if ($python_version[0] -ge 3 -and $python_version[1] -ge $PYTHON_MINOR_VERSION) {
            Write-Host "Python version is greater than or equal to 3.$PYTHON_MINOR_VERSION, skipping pyenv installation."
            return
        }
    }
        
    WriteInfo "Installing pyenv for Windows..."
    $downloads_path = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "$downloads_path\install-pyenv-win.ps1"
    
    &"$downloads_path\install-pyenv-win.ps1"
    
    WriteInfo 'Pyenv installation complete. Please restart your terminal to apply changes.'
}