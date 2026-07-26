function set_log_dir {
    if (!(Test-Path variable:RUN_ID)) {
        Write-output "RUN_ID not set, using default value: 001"
        $Script:RUN_ID = "001"
    }

    $Script:LOG_DIR = "$LOG_BASE\$RUN_ID"
    if (!(Test-Path -PathType Container $LOG_DIR)) {
        New-Item -Path $LOG_DIR -ItemType Directory -Force | Out-Null
    }

    if (Test-Path variable:DEBUG) {
        Write-output "Debug mode" 
        $DebugPreference = 'Continue'
        $VerbosePreference = 'Continue'
        try {
            Get-ChildItem $LOG_DIR | Remove-Item -Recurse -ErrorAction SilentlyContinue
        } catch {
            Write-Output "Error deleting $_"
        }
    }

    $Script:LOG_FILE = "$LOG_DIR\ps1_default.log"
    if (!(Test-Path -PathType Leaf $LOG_FILE)) {
        New-Item -Path $LOG_FILE -ItemType File -Force | Out-Null
    }
}

function CheckEventLogSource {
    [CmdletBinding()]
    param ($Source)
    [System.Diagnostics.EventLog]::SourceExists($Source)
}

function WriteLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Critical', 'Important', 'Output', 'Host', 'Significant', 'VeryVerbose', 'Verbose', 'SomewhatVerbose', 'System', 'Debug', 'InternalComment', 'Warning', 'Error', 'Info')]
        [string]$Level = 'Significant'
    )

    if (!(Test-Path variable:LOG_FILE)) { set_log_dir }

    $Message = $Message -replace 'step already done', $TICK_MARK
    $Message = $Message -replace 'stage completed', $TICK_MARK
    $Message = $Message -replace 'step failed', $CROSS_MARK

    $EventLogEnabled = $false
    # WriteDebug "get_context event_log_source: $(get_context event_log_source)"
    if($(get_context event_log_source) -eq 'pipeline1') { $EventLogEnabled = $true }
    # WriteDebug "EventLogEnabled: $EventLogEnabled"
    switch ($Level) {
        Verbose { Write-Verbose "$Message" }
        Warning { 
            Write-Warning $Message
            Add-Content -Path $LOG_FILE -Value "$Message"
            if ($EventLogEnabled) { Write-EventLog -LogName Application -Source 'pipeline1' -EntryType Warning -EventId 1 -Message $Message }
        }
        Error { 
            Write-Warning "$Message"
            Add-Content -Path $LOG_FILE -Value "$Message"
            if ($EventLogEnabled) { Write-EventLog -LogName Application -Source 'pipeline1' -EntryType Error -EventId 1 -Message $Message }
        }
        Debug { 
            Write-Debug "$Message"
            Add-Content -Path $LOG_FILE -Value "$Message"
        }
        Info { 
            Write-Information "$Message"   -InformationAction Continue
            # if ($EventLogEnabled) { Write-EventLog -LogName Application -Source 'pipeline1' -EntryType Warning -EventId 1 -Message $Message }
            Add-Content -Path $LOG_FILE -Value "$Message"
        }
        default { WriteInfo "$Message" }
    }
}

function WriteError ($Message) {
    WriteLog -Level Error $Message
    exit 1
}

function WriteWarn ($Message) {
    WriteLog -Level Warning $Message
}

function WriteWarning ($Message) {
    WriteWarn $Message
}

function WriteInfo ($Message) {
    WriteLog -Level Info $Message
}

function WriteDebug ($Message) {
    $CallingFunction = [string]$(Get-PSCallStack)[1].FunctionName
    if ($Callingfunction -eq "<ScriptBlock>") {
        $CallingFunction = $MyInvocation.PSCommandPath
    }

    # WriteLog -Level Debug "$Callingfunction`: $Message"
    WriteLog -Level Info "$Callingfunction`: $Message"
}
