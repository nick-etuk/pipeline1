function get_step_description($StepID) {
    # replace underscores with spaces
    $Descr = $StepID -replace '_', ' '

    # capitalize first letter
    $Descr = $Descr.Substring(0, 1).ToUpper() + $Descr.Substring(1)
    return $Descr
}
