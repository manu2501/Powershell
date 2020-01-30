cls
Write-Host ""
Write-Host "                    Welcome to Checkouts Script" -ForegroundColor Cyan


if ((Test-Path -PathType Container D:\checkouts\out) -eq 0)
{
    mkdir D:\checkouts\out > $null
}


$delFiles = "D:\checkouts\out\DBstatus.txt","D:\checkouts\out\Serviceshealth.txt", "D:\checkouts\out\Diskspace.txt", "D:\checkouts\out\McAfeeServices.txt", "D:\checkouts\out\RHcheck.txt"


foreach($file in $delFiles)
{
    if(Test-Path $file)
    {
        Remove-Item $file
    }
}



echo "=========================================================================================================="

$a = Read-Host "`n1)Pre Checks `n2)Post Checks without rebalance `n3)Post Checks with rebalance `n4)Rebalance `n`nEnter your Choice  "


echo "=========================================================================================================="
switch($a)
{
    1 {
        echo "==========================================================================================================================="

        $servers = gc D:\Checkouts\ServerList.txt

        foreach($server in $servers)
        {
            $MailServers = Get-MailboxDatabase -Server $server | Select servers -First 1 | Sort servers
            $i = 1
            ($MailServers.Servers).ForEach({
                if($PSItem.Name -ne $server)
                {
                    New-Variable -Name "Server$i" -Value $PSItem.Name
                    $i++
                }
            })
    
    
            echo "The server is $server", "Select the below partner servers which you want to move ::", 1.$server1, 2.$Server2, 3.$Server3


           $Select = Read-Host "Enter your selection"

           switch($Select)
           {
            1 {Move-ActivemailboxDatabase -server $server -ActivateonServer $server1 ; Break}
            2 {Move-ActivemailboxDatabase -server $server -ActivateonServer $server2 ; Break}
            3 {Move-ActivemailboxDatabase -server $server -ActivateonServer $server3 ; Break}
           }

           echo "==========================================================================================================================="
           Remove-Variable -Name "Server1"
           Remove-Variable -Name "Server2"
           Remove-Variable -Name "Server3"
        }
    }

    2 {

        $servers = gc D:\checkouts\ServerList.txt

        foreach($server in $servers)
        {
            echo $server
            echo "============="  


            echo "checking DB status" 
            echo $server >> D:\checkouts\out\DBstatus.txt
            echo "===========" >> D:\checkouts\out\DBstatus.txt
            Get-MailboxDatabaseCopyStatus -server $server | ft -au >> D:\checkouts\out\DBstatus.txt
	
            echo "Checking Service Health"    
            echo $server >> D:\checkouts\out\Serviceshealth.txt
            echo "===========" >> D:\checkouts\out\Serviceshealth.txt 
            Test-ServiceHealth -server $server >> D:\checkouts\out\Serviceshealth.txt

   
            echo "checking Disk Space"
            echo $server >> D:\checkouts\out\Diskspace.txt
            echo "===========" >> D:\checkouts\out\Diskspace.txt
            Get-WmiObject win32_logicaldisk -ComputerName $server | Select-Object DeviceID,Size,FreeSpace | ft -au >> D:\checkouts\out\Diskspace.txt

            echo "checking McAfee Services"
            echo $server >> D:\checkouts\out\McAfeeServices.txt
            echo "===========" >> D:\checkouts\out\McAfeeServices.txt
            Get-Service -ComputerName $server -DisplayName "McAfee*" | select -First 8 | ft -au >> D:\checkouts\out\McAfeeServices.txt

   
            echo "Testing Replication Health"
            echo $server >> D:\checkouts\out\RHcheck.txt
            echo "===========" >> D:\checkouts\out\RHcheck.txt
            Test-ReplicationHealth -Identity $server | ft -au >> D:\checkouts\out\RHcheck.txt
    
            echo " "

        }
    }
    
    3 {
        $servers = gc D:\checkouts\ServerList.txt

        foreach($server in $servers)
        {
          $DBs = Get-MailboxDatabase -Server $server | Select-Object name, server -ExpandProperty activationpreference | Where-Object {$_.Key -like $server -and $_.Value -eq 1}
 
          foreach($DB in $DBs.Name)
          { 
            $ps = Get-MailboxDatabase -Identity $DB | Select-Object name,server
            $ps = $ps.server.name
            if($ps -ne $server)
            {
                Write-Host "considering the move of $DB from $ps to $server" -ForegroundColor Yellow
                Move-ActiveMailboxDatabase -Identity $DB -ActivateOnServer $server
        
            }
            else
            {
               Write-Host "$DB is already in $server" -ForegroundColor Green
            }

            echo "---------------------------------------------------------------------------------------"
          }
        }



$servers = gc D:\checkouts\ServerList.txt

foreach($server in $servers)
{
    echo $server
    echo "============="  


    echo "checking DB status" 
    echo $server >> D:\checkouts\out\DBstatus.txt
    echo "===========" >> D:\checkouts\out\DBstatus.txt
    Get-MailboxDatabaseCopyStatus -server $server | ft -au >> D:\checkouts\out\DBstatus.txt
	
    echo "Checking Service Health"    
    echo $server >> D:\checkouts\out\Serviceshealth.txt
    echo "===========" >> D:\checkouts\out\Serviceshealth.txt 
    Test-ServiceHealth -server $server >> D:\checkouts\out\Serviceshealth.txt

   
    echo "checking Disk Space"
    echo $server >> D:\checkouts\out\Diskspace.txt
    echo "===========" >> D:\checkouts\out\Diskspace.txt
    Get-WmiObject win32_logicaldisk -ComputerName $server | Select-Object DeviceID,Size,FreeSpace | ft -au >> D:\checkouts\out\Diskspace.txt

    echo "checking McAfee Services"
    echo $server >> D:\checkouts\out\McAfeeServices.txt
    echo "===========" >> D:\checkouts\out\McAfeeServices.txt
    Get-Service -ComputerName $server -DisplayName "McAfee*" | select -First 8 | ft -au >> D:\checkouts\out\McAfeeServices.txt

   
    echo "Testing Replication Health"
    echo $server >> D:\checkouts\out\RHcheck.txt
    echo "===========" >> D:\checkouts\out\RHcheck.txt
    Test-ReplicationHealth -Identity $server | ft -au >> D:\checkouts\out\RHcheck.txt
    
    echo " "

}

}
    
    4 {
        $servers = gc D:\checkouts\ServerList.txt

        foreach($server in $servers)
        {
          $DBs = Get-MailboxDatabase -Server $server | Select-Object name, server -ExpandProperty activationpreference | Where-Object {$_.Key -like $server -and $_.Value -eq 1}
 
          foreach($DB in $DBs.Name)
          { 
            $ps = Get-MailboxDatabase -Identity $DB | Select-Object name,server
            $ps = $ps.server.name
            if($ps -ne $server)
            {
                Write-Host "considering the move of $DB from $ps to $server" -ForegroundColor Yellow
                Move-ActiveMailboxDatabase -Identity $DB -ActivateOnServer $server
        
            }
            else
            {
               Write-Host "$DB is already in $server" -ForegroundColor Green
            }

            echo "---------------------------------------------------------------------------------------"
          }
        }
    }


}
