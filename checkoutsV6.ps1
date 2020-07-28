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
function Failover($servers) {
    Clear-Host
    Write-Host "`nPerforming Database Movement based on your selection`n----------------------------------------------------" -ForegroundColor Cyan
    $Serverlist = $servers

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
function Failover2($servers) {
    Clear-Host
    Write-Host "`nPerforming Database Movement to Activation Preference 2 server`n--------------------------------------------------------------" -ForegroundColor Cyan
    $Serverlist = $servers

    foreach ($server in $serverlist) {
        $DB = Get-MailboxDatabase -Server $server -Status | Select-Object name -ExpandProperty Activationpreference | Where-Object { $_.key -like $Server -and $_.value -eq 1 } | Select-Object name -First 1
        $DB = Get-MailboxDatabase -Identity $DB.Name -Status | Select-Object name -ExpandProperty Activationpreference
        $server2 = ($DB | Select-Object name, key -ExpandProperty value | Where-Object { $_ -eq 2 } | Select-Object key).key.Name
        Write-Host "The DBs are moving from $server to $server2"
        Write-Output "Move-ActiveMailboxDatabase -server $server -ActivateOnServer $server2"
    }
}
function Failover3($servers) {
    Clear-Host
    Write-Host "`nPerforming Database Movement to Activation Preference 3 server`n--------------------------------------------------------------" -ForegroundColor Cyan
    $Serverlist = $servers

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

function DAGRebalance($servers) {
}

#main Part
Clear-Host

if (Test-Path -Path $Path) {
    $servers = Get-Content -Path $Path | Sort-Object 
}
else {
    $servers = $env:COMPUTERNAME
}


Remove-Item "D:\checkouts\out\*"

Write-Host "Welcome to Checkouts Script" -ForegroundColor Green

ShowMenu

$selection = Read-Host "`nPlease make a selection (1 to 7)  "

switch ($selection) {
    '1' {
        Failover($servers)
    }
    '2' {
        Failover2($servers)
    } 
    '3' {
        Failover3($servers)
    } 
    '4' {
        Write-Host "Rebalancing the Databases for the given Servers`n-----------------------------------------------" -ForegroundColor Cyan
        foreach ($server in $servers) {
            Rebalance($server)
        }
    }
    '5' {
        Write-Host "Rebalancing the Databases for the given DAGs`n-----------------------------------------------" -ForegroundColor Cyan  
        foreach ($DAG in $servers) {
            DAGRebalance($DAG)
        } 
    }

    '6' {

    }
    '7' {

    }
    'q' {
        return
    }
}