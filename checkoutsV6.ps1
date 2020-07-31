#Parameters part

[CmdletBinding()]
param (
    [String]$Path = 0
)

#Functions Part
#showMenu function used to diplay the Menu for the activitess
function ShowMenu {
    Write-Host "`n1. Move Databases to Partner server based on your selection"
    Write-Host "2. Move Databases to Activation Preference 2 server"
    Write-Host "3. Move Databases to Activation Preference 3 server"
    Write-Host "4. Rebalance the Databases for the given Servers"
    Write-Host "5. Rebalance the Databases for the servers in given DAGs"
    Write-Host "6. Perform every Server Health Checks"
    Write-Host "7. Perform every Server Health Checks with Rebalance"
    Write-Host "8. perform particular server Health checks"
    Write-Host "Press Q to Exit" 
}
function Failover($content) {
    Clear-Host
    Write-Host "`nPerforming Database Movement based on your selection`n----------------------------------------------------" -ForegroundColor Cyan
    $Serverlist = $content

    foreach ($server in $serverlist) {
        $DB = Get-MailboxDatabase -Server $server -Status | Select-Object name -ExpandProperty Activationpreference | Where-Object { $_.key -like $Server -and $_.value -eq 1 } | Select-Object name -First 1
        $DB = Get-MailboxDatabase -Identity $DB.Name -Status | Select-Object name -ExpandProperty Activationpreference
        $server2 = ($DB | Select-Object name, key -ExpandProperty value | Where-Object { $_ -eq 2 } | Select-Object key).key.Name
        $server3 = ($DB | Select-Object name, key -ExpandProperty value | Where-Object { $_ -eq 3 } | Select-Object key).key.Name
        Write-Host "The Server is $server"
        Write-Host "1.$server2 (AP = 2)"
        Write-Host "2.$server3 (AP = 3)"
        $Select = Read-Host "Enter your selection (1 or 2) "

        switch ($Select) {
            1 { Write-Output "Move-ActivemailboxDatabase -server $server -ActivateonServer $server2" ; Break }
            2 { Write-Output "Move-ActivemailboxDatabase -server $server -ActivateonServer $server3" ; Break }
        }

        Write-Output "==================================================================================================="
    } 
}
function Failover2($content) {
    Clear-Host
    Write-Host "`nPerforming Database Movement to Activation Preference 2 server`n--------------------------------------------------------------" -ForegroundColor Cyan
    $Serverlist = $content

    foreach ($server in $serverlist) {
        $DB = Get-MailboxDatabase -Server $server -Status | Select-Object name -ExpandProperty Activationpreference | Where-Object { $_.key -like $Server -and $_.value -eq 1 } | Select-Object name -First 1
        $DB = Get-MailboxDatabase -Identity $DB.Name -Status | Select-Object name -ExpandProperty Activationpreference
        $server2 = ($DB | Select-Object name, key -ExpandProperty value | Where-Object { $_ -eq 2 } | Select-Object key).key.Name
        Write-Host "The DBs are moving from $server to $server2"
        Write-Output "Move-ActiveMailboxDatabase -server $server -ActivateOnServer $server2"
    }
}
function Failover3($content) {
    Clear-Host
    Write-Host "`nPerforming Database Movement to Activation Preference 3 server`n--------------------------------------------------------------" -ForegroundColor Cyan
    $Serverlist = $content

    foreach ($server in $serverlist) {
        $DB = Get-MailboxDatabase -Server $server -Status | Select-Object name -ExpandProperty Activationpreference | Where-Object { $_.key -like $Server -and $_.value -eq 1 } | Select-Object name -First 1
        $DB = Get-MailboxDatabase -Identity $DB.Name -Status | Select-Object name -ExpandProperty Activationpreference
        $server3 = ($DB | Select-Object name, key -ExpandProperty value | Where-Object { $_ -eq 3 } | Select-Object key).key.Name
        Write-Host "The DBs are moving from $server to $server3"
        Write-Output "Move-ActiveMailboxDatabase -server $server -ActivateOnServer $server3"
    }
}
function Rebalance($server) {
   
    $DBs = Get-MailboxDatabase -Server $server | Select-Object name, server -ExpandProperty activationpreference | Where-Object { $_.Key -like $server -and $_.Value -eq 1 }
 
    foreach ($DB in $DBs.Name) { 
        $ps = Get-MailboxDatabase -Identity $DB | Select-Object name, server
        $ps = $ps.server.name
        if ($ps -ne $server) {
            Write-Host "considering the move of $DB from $ps to $server" -ForegroundColor Yellow
            Write-Output "Move-ActiveMailboxDatabase -Identity $DB -ActivateOnServer $server"
        
        }
        else {
            Write-Host "$DB is already in $server" -ForegroundColor Green
        }

        Write-Output "--------------------------------------------"
    }
}
function DAGRebalance($DAG) {
    $servers = Get-DatabaseAvailabilityGroup -Identity $DAG | Select-Object -ExpandProperty:Servers
    foreach ($server in $servers) {
        Rebalance($server)
    }
}
function RHCheck($server) {
    Write-Output "Testing Replication Health"
    Write-Output $server >> D:\checkouts\out\RHcheck.txt
    Write-Output "===========" >> D:\checkouts\out\RHcheck.txt
    Test-ReplicationHealth -Identity $server | Format-Table -au >> D:\checkouts\out\RHcheck.txt
}
function ServiceHealth($server) {
    Write-Output "Checking Service Health"    
    Write-Output $server >> D:\checkouts\out\Serviceshealth.txt
    Write-Output "===========" >> D:\checkouts\out\Serviceshealth.txt 
    Test-ServiceHealth -server $server >> D:\checkouts\out\Serviceshealth.txt
}
function McAfeeCheck($server) {
    Write-Output "checking McAfee Services"
    Write-Output $server >> D:\checkouts\out\McAfeeServices.txt
    Write-Output "===========" >> D:\checkouts\out\McAfeeServices.txt
    Get-Service -ComputerName $server -DisplayName "McAfee*" | Select-Object -First 8 | Format-Table -au >> D:\checkouts\out\McAfeeServices.txt
}
function LastReboot($server) {

}
function DrivesCheck($server) {
    Write-Output "checking Drives Space"
    Write-Output $server >> D:\checkouts\out\Diskspace.txt
    Write-Output "===========" >> D:\checkouts\out\Diskspace.txt
    Get-WmiObject win32_logicaldisk -ComputerName $server | Select-Object DeviceID, Size, FreeSpace | Format-Table -au >> D:\checkouts\out\Diskspace.txt

}
function DBCheck($server) {
    Write-Output $server >> D:\checkouts\out\DBstatus.txt
    Write-Output "===========" >> D:\checkouts\out\DBstatus.txt
    Get-MailboxDatabaseCopyStatus -server $server | Format-Table -au >> D:\checkouts\out\DBstatus.txt
}
function SubMenu {
    Clear-Host
    write-Host "Select the below particular checks`n" -BackgroundColor Cyan
    Write-Host "`n1. Last Reboot"
    Write-Host "2. Database checks"
    Write-Host "3. Service Health"
    write-host "4. Drives Check"
    Write-Host "5. McAfee Services check"
    Write-Host "6. Replication Health check"
}



#main Part
Clear-Host

if (Test-Path -Path $Path) {
    $content = Get-Content -Path $Path | Sort-Object 
}
else {
    $content = $env:COMPUTERNAME
}


Remove-Item "D:\checkouts\out\*" > $0

Write-Host "Welcome to Checkouts Script" -ForegroundColor Green

ShowMenu

$selection = Read-Host "`nPlease make a selection (1 to 7)  "

switch ($selection) {
    '1' {
        Failover($content)
    }
    '2' {
        Failover2($content)
    } 
    '3' {
        Failover3($content)
    } 
    '4' {
        Write-Host "Rebalancing the Databases for the given Servers`n-----------------------------------------------" -ForegroundColor Cyan
        foreach ($server in $content) {
            Rebalance($server)
        }
    }
    '5' {
        Write-Host "Rebalancing the Databases for the given DAGs`n-----------------------------------------------" -ForegroundColor Cyan  
        foreach ($DAG in $content) {
            DAGRebalance($DAG)
        } 
    }
    '6' {
        Write-Host "Performing post Checks for the given Servers without Rebalancing`n-----------------------------------------------" -ForegroundColor Cyan
        foreach ($server in $content) {
            Write-Host "Running Checkouts for the server $Server" -ForegroundColor DarkGray
            LastReboot($server)
            DBCheck($server)
            ServiceHealth($server)
            DrivesCheck($server)
            McAfeeCheck($server)
            RHCheck($server)
            Write-Host "`n"
        }

    }
    '7' {
        Write-Host "Performing post Checks for the given Servers with Rebalancing`n-----------------------------------------------" -ForegroundColor Cyan
        foreach ($server in $content) {
            Write-Host "Running Checkouts for the server $Server" -ForegroundColor DarkGray
            Rebalance($server)
            LastReboot($server)
            DBCheck($server)
            ServiceHealth($server)
            DrivesCheck($server)
            McAfeeCheck($server)
            RHCheck($server)
            Write-Host "`n"
        }

    }
    '8' {
        subMenu
        $selection2 = Read-Host "`n select the options (1 to 6) "

        switch ($selection2) {
            '1' {
                foreach ($server in $content) {
                    LastReboot($server)
                }

            }
            '2' {
                foreach ($server in $content) {
                    DBCheck($server)
                }
            }
            '3' {
                foreach ($server in $content) {
                    ServiceHealth($server)
                }
            }
            '4' {
                foreach ($server in $content) {
                    DrivesCheck($server)
                }
            }
            '5' {
                foreach ($server in $content) {
                    McAfeeCheck($server)
                }
            }
            '6' {
                foreach ($server in $content) {
                    RHCheck($server)
                }
            }
        }
    }
    'q' {
        return
    }
}