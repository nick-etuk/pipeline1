function get_context {
    switch($args.Length) {
        1 {
            $Key = $args[0]
            $Group = 'global'
        }
        2 {
            $Key = $args[0]
            $Group = $args[1]
        }
        default {
            WriteWarn "Invalid number of arguments for get_context: $($args.Length) arguments - $($args -join ', ')"
        }
    }

    $ContextFile = "$WORKING_DIR\context\$Group\$Key.txt"

    if (!(Test-Path "$WORKING_DIR\context\$Group" -PathType Container)) {
        return
    }

    if (!(Test-Path $ContextFile)) {
        return
    }

    $Value = Get-Content $ContextFile
    $Value = $Value.Trim()
    return $Value
}
