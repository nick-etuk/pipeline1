param (
    $Arguments
)

if (!$Arguments) {
    WriteError "An argument is required for add_event_log_source"
}
New-EventLog -LogName Application -Source $Arguments
set_context event_log_source $Arguments
