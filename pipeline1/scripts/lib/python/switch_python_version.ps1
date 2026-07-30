function switch_python_version {
    if (!(Get-Command pyenv -ErrorAction SilentlyContinue)) { return }

    $python_command = Get-Command python -ErrorAction SilentlyContinue
    if ($python_command) {
        $python_version = (python --version 2>&1)
        $major_version, $minor_version, $patch_version = $python_version -replace 'Python ', '' -split '\.'
        if ($major_version -eq $PYTHON_MAJOR_VERSION -and $minor_version -eq $PYTHON_MINOR_VERSION) {
            return
        }
    }
        
    WriteInfo "Switching to Python $PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION ..."
    pyenv install "$PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION"
    pyenv global "$PYTHON_MAJOR_VERSION.$PYTHON_MINOR_VERSION"
}