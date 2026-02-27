function get_first_activity($ProjectID) {
    if (-not $ProjectID) {
        WriteError "Project ID is required"
        return
    }
    
    $ActivityRegistry = "$WORKING_DIR/activity_registry.csv"
    if (!(Test-Path -Path $ActivityRegistry)) {
        WriteError "Activity registry not found at $ActivityRegistry"
        return
    }
    $RegistryContent = Import-CSV $ActivityRegistry
    if (!$RegistryContent) {
        WriteError "Activity registry is empty or could not be read: $ActivityRegistry"
        return
    }
    $matching_activities = $RegistryContent | Where-Object { $_.project_id -eq $ProjectID }
    if (!$matching_activities) {
        WriteError "No activities found for project ID: $ProjectID"
        return
    }
    # Get the first activity for the project
    $first_activity = $matching_activities | Select-Object -First 1
    if (!$first_activity) {
        WriteError "No activities found for project ID: $ProjectID"
        return
    }
    $CURRENT_ACTIVITY = $first_activity.activity_id
    Set-Config 'current_activity' "$CURRENT_ACTIVITY"
    echo "First activity for project $ProjectID is $CURRENT_ACTIVITY"
}