function set_context {
    switch($args.Length) {
        2 {
            $Key = $args[0]
            $Value = $args[1]
            $Group = 'global'
        }
        3 {
            $Key = $args[0]
            $Value = $args[1]
            $Group = $args[2]
        }
        default {
            Write-Error "Invalid number of arguments for set_context: $($args.Length) arguments - $($args -join ', ')"
            # writeError "$($args.Length) arguments - $($args -join ', ')"
        }
    }

    if ($(get_context $args) -eq $Value) {
        # WriteDebug "$($args -join ' ') unchanged from '$Value'"
        return
    }
    
    if (!(Test-Path -PathType Container "$WORKING_DIR\context\$Group")) {
        New-Item -ItemType Directory -Path "$WORKING_DIR\context\$Group" | Out-Null
    }

    $ConfigFile = "$WORKING_DIR\context\$Group\$Key.txt"
    if (!(Test-Path $ConfigFile)) {
        New-Item -ItemType File -Path $ConfigFile | Out-Null
    }

    Set-Content -Path $ConfigFile -Value $Value
}
