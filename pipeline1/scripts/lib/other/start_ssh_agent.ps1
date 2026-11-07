function start_ssh_agent {
    $service = Get-Service -Name ssh-agent
    if ($service.Status -ne 'Running') {
        WriteInfo "Starting SSH agent service..."
        $service | Set-Service -StartupType Automatic
        Start-Service ssh-agent
        ssh-add $HOME\.ssh\id_ed25519
        # Enter pass phrase when prompted
        # You should see a message like:
        # Identity added: c:/Users/NIET2/.ssh/id_ed25519 (nick.etuk2@nhs.net)
    }
}
