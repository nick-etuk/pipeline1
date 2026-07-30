function old_switch_python_version {
    if (!(Get-Command pyenv -ErrorAction SilentlyContinue)) { return }

    $python_command = Get-Command python -ErrorAction SilentlyContinue
    if ($python_command) {
        $pythonFile = Get-Item $python_command.Source -ErrorAction SilentlyContinue
        if ($pythonFile -and $pythonFile.VersionInfo) {
            $python_version = $pythonFile.VersionInfo.ProductVersion.Split(".")
            if ($python_version[0] -eq $PYTHON_MAJOR_VERSION -and $python_version[1] -eq $PYTHON_MINOR_VERSION) {
                Write-Host "Python version is already $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION, skipping pyenv installation."
                return
            }
        }
    }
        
    WriteInfo "Switching to Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION ..."
    pyenv install "$PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION"
    pyenv global "$PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION"
}