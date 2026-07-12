function get_context {
    $Script:CURRENT_PROJECT_ID = get_context 'current_project_id'
    $Script:DEFAULT_STEP_PATH = get_context 'default_step_path'
    return
}