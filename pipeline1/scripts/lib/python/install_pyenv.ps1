function install_pyenv_windows {
    if (Get-Command pyenv -ErrorAction SilentlyContinue) { return }

    # exit if python version is greater than or equal to 3.$PYTHON_MINOR_VERSION
    if ((Get-Command python).FileVersionInfo.ProductVersion.Split(".")[0] -ge 3 -and
        (Get-Command python).FileVersionInfo.ProductVersion.Split(".")[1] -ge $PYTHON_MINOR_VERSION) {
        Write-Host "Python version is greater than or equal to 3.$PYTHON_MINOR_VERSION, skipping pyenv installation."
        return
    }
    WriteInfo "Installing pyenv for Windows..."
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
    pyenv install "3.$PYTHON_MINOR_VERSION"
    pyenv global "3.$PYTHON_MINOR_VERSION"

}