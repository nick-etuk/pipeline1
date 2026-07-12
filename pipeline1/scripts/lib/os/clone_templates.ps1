function clone_templates {
    # if ($(get_context templates_cloned  status) -eq 'done') { return }
    Set-Location $REPO_DIR
    git clone https://github.com/nick-etuk/pipeline1-template-web.git
    # set_context templates_cloned 'done'  status
    Set-Location $P1_ROOT_WIN
}
