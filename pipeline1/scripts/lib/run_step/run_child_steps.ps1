function RunChildSteps {
    param (
        $ChildSteps,
        $ParentArgs = ''
    )

    $AllDone = 0
    foreach ($ChildStep in $ChildSteps) {
        if(!$ChildStep.contains(' ')) {
            $ChildStep = $ChildStep -replace '_', '-'
            if (!(RunStep -StepID $ChildStep)) {
                $AllDone = 1
            }
            continue
        }
        $Split = $ChildStep.split()
        $ChildStepID = $Split[0]
        $ChildStepID = $ChildStepID -replace '_', '-'
        $ChildStepArgs = $Split[1..($Split.length)]
        
        $CombinedStepArgs = $ChildStepArgs -replace '\$\@', $ParentArgs
        WriteDebug "Child and parent args: $CombinedStepArgs"
        if (!(RunStep -StepID $ChildStepID -Arguments $CombinedStepArgs)) {
            $AllDone = 1
        }
    }

    return $AllDone
}
