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

    $Message = $Message -replace 'step already done', $TICK_MARK
    $Message = $Message -replace 'stage completed', $TICK_MARK
    $Message = $Message -replace 'step failed', $CROSS_MARK

    $EventLogEnabled = $false
    # WriteDebug "Get-Config event_log_source: $(Get-Config event_log_source)"
    if($(Get-Config event_log_source) -eq 'pipeline1') { $EventLogEnabled = $true }
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
