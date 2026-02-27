function clone_templates {
    # if ($(Get-Config templates_cloned  status) -eq 'done') { return }
    Set-Location $REPO_DIR
    git clone https://github.com/nick-etuk/pipeline1-template-web.git
    # Set-Config templates_cloned 'done'  status
    Set-Location $P1_ROOT_WIN
}
