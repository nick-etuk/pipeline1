Param (
    [Parameter(Position=0)]
    $IDE,
    [Parameter(Position=1)]
    $location
)

function start_executable($filename, $location) {
    $exe_path = get_context $filename 'file_paths'
    if (!($exe_path)) {
        $exe_path = Find-Executable $filename
        if (!($exe_path)) {
            WriteWarn "$filename not found."
            WriteWarn 'Please install the application in one of the normal installation directories,'
            WriteWarn 'or add it to your PATH.'
            return
        }
    }
    Start-Process $exe_path -ArgumentList "$location"
}

function open_ide ($IDE, $location) {
    switch ($IDE) {
        android_studio {
            $exe_path = get_context 'studio64.exe' 'file_paths'
            WriteWarn 'or add it to your PATH.'
            return
        }
    }
}

function open_ide ($IDE, $location) {
    switch ($IDE) {
        android_studio {
            start_executable 'studio64.exe' $location
            wait_for_ide 'android_studio'
        }
        intellij { 
            start_executable 'idea64.exe' $location
            wait_for_ide 'intellij'
        }
        vscode {
            # VS Code should already be on the PATH
            Start-Process 'code' -ArgumentList "$location"
            wait_for_ide 'vscode'
        }
    }
}

open_ide $IDE $location
