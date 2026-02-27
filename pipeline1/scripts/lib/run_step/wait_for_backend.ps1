function IsRunning {
    param (
        [Parameter()]
        $Container
    )

    if (wsl -u $P1_USER_UNIX docker container ls --format '{{.Names}}' | Select-String -Pattern $Container) {
        return $true
    }
    return $false
}

function Wait-For-Backend {
    Param (
        $Service
    )
    
    $WebContainers = @(
                "nhsapp-api.local.bitraft.io-1",
                "nhsapp-pfs.local.bitraft.io-1",
                "nhsapp-cid.local.bitraft.io-1",
                "nhsapp-servicejourneyrulesapi.local.bitraft.io-1",
                "nhsapp-silver.local.bitraft.io-1",
                "nhsapp-mongodb.bitraft.io-1",
                "nhsapp-web.local.bitraft.io-1"
            )

    switch ($Service) {
        web { 
            $Containers = $WebContainers
        }
        bdd { 
            $Containers = @(
                "int_test-api.local.bitraft.io-1",
                "int_test-pfs.local.bitraft.io-1",
                "int_test-cid.local.bitraft.io-1",
                "int_test-servicejourneyrulesapi.local.bitraft.io-1",
                "int_test-web.local.bitraft.io-1",
                "int_test-stubs.local.bitraft.io-1",
                "int_test-silver.local.bitraft.io-1",
                "int_test-mongodb.bitraft.io-1"
            )
        }
        android { 
            $Containers = $WebContainers + "nhsapp-dns-1"
        }
        Default {}
    }
    
    $WaitTime = 0
    $MaxWaitTime = 60
    foreach ($Container in $Containers) {
        WriteInfo -NoNewline "`nWaiting for $Service backend container $Container "
        while (!(IsRunning -Container $Container) -or ($WaitTime -gt $MaxWaitTime)) {
            WriteInfo -NoNewline "."
            Start-Sleep -Seconds 3
            $WaitTime += 3

        }
        
        if ($WaitTime -gt $MaxWaitTime) {
            WriteInfo "`n"
            WriteInfo "$Service Backend containers not started after $MaxWaitTime seconds."
            break
        }
    }
    WriteInfo "`n"    
}
