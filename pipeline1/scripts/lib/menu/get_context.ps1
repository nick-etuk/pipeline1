function get_context {
    $Script:CURRENT_PROJECT_ID = Get-Config 'current_project_id'
    $Script:DEFAULT_STEP_PATH = Get-Config 'default_step_path'
    return
}