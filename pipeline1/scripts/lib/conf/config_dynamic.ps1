function Get-Config {
    switch($args.Length) {
        1 {
            $Key = $args[0]
            $Group = 'general'
        }
        2 {
            $Key = $args[0]
            $Group = $args[1]
        }
        default {
            WriteError "Invalid number of arguments for Get-Config: $($args.Length) arguments - $($args -join ', ')"
            # writeError "$($args.Length) arguments - $($args -join ', ')"
        }
    }

    $ConfigFile = "$WORKING_DIR\dynamic_config\$Group\$Key.txt"

    if (!(Test-Path "$WORKING_DIR\dynamic_config\$Group" -PathType Container)) {
        return
    }

    if (!(Test-Path $ConfigFile)) {
        return
    }

    $Value = Get-Content $ConfigFile
    return $Value
}

function Set-Config {
    switch($args.Length) {
        2 {
            $Key = $args[0]
            $Value = $args[1]
            $Group = 'general'
        }
        3 {
            $Key = $args[0]
            $Value = $args[1]
            $Group = $args[2]
        }
        default {
            Write-Error "Invalid number of arguments for Set-Config: $($args.Length) arguments - $($args -join ', ')"
            # writeError "$($args.Length) arguments - $($args -join ', ')"
        }
    }

    if ($(Get-Config $args) -eq $Value) {
        # WriteDebug "$($args -join ' ') unchanged from '$Value'"
        return
    }
    
    if (!(Test-Path -PathType Container "$WORKING_DIR\dynamic_config\$Group")) {
        New-Item -ItemType Directory -Path "$WORKING_DIR\dynamic_config\$Group" | Out-Null
    }

    $ConfigFile = "$WORKING_DIR\dynamic_config\$Group\$Key.txt"
    if (!(Test-Path $ConfigFile)) {
        New-Item -ItemType File -Path $ConfigFile | Out-Null
    }

    Set-Content -Path $ConfigFile -Value $Value
}
