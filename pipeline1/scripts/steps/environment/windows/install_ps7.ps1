function Install-PS7 {

    if (!(Invoke-Step-Entry)) { return }

    winget install --id Microsoft.Powershell --source winget

    Invoke-Step-Exit
}