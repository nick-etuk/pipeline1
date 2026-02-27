function list_steps {
    update_step_registry
    $StepRegistry = "$WORKING_DIR/step_registry.csv"
    if (!(Test-Path -Path $StepRegistry)) {
        WriteError "Step registry not found at $StepRegistry"
        return
    }

    $StepRegistryContent = Import-CSV $StepRegistry
    if (!$StepRegistryContent) {
        WriteError "Step registry is empty or could not be read: $StepRegistry"
        return
    }

    $StepRegistryContent | Format-Table
}
