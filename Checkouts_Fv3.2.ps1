############################################################
## Pre, Post and Rebalance Script for 2016 Exchange Servers
## Written by Kothuru, Manoj Kumar
############################################################


Param(
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [String[]]
    $Serverlist
)


cls
Write-Host ""
Write-Host "                    Welcome to Checkouts Script" -ForegroundColor Cyan


if ((Test-Path -PathType Container D:\checkouts) -eq 0)
{
    mkdir D:\checkouts > $null
}

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
        $Serverlist = Get-Content $Serverlist

        foreach($server in $serverlist)
        {
            $DB = Get-MailboxDatabase -Server $Server -Status | select name -ExpandProperty Activationpreference | Where-Object {$_.key -like $Server -and $_.value -eq 1} | select name -First 1
            $DB = Get-MailboxDatabase -Identity $DB.Name -Status | select name -ExpandProperty Activationpreference
            $server2 = ($DB | select name,key -ExpandProperty value|Where-Object { $_ -eq 2 }| select key).key.Name
            $server3 = ($DB | select name,key -ExpandProperty value|Where-Object { $_ -eq 3 }| select key).key.Name
            echo "The Server is $server"
            echo "1.$server2 (AP = 2)"
            echo "2.$server3 (AP = 3)"
            $Select = Read-Host "Enter your selection (1 or 2) "

            switch($Select)
            {
                1 {Move-ActivemailboxDatabase -server $server -ActivateonServer $server2 ; Break}
                2 {Move-ActivemailboxDatabase -server $server -ActivateonServer $server3 ; Break}
            }

            echo "==================================================================================================="
         } 
         $Serverlist | ForEach-Object { Get-MailboxDatabaseCopyStatus -Server $_ ; echo "---------------------------------------------------------------------------------------------------------------------------" } >> D:\checkouts\out\DBstatus.txt
    }


    2 {

        $servers = gc $Serverlist

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
        $servers = gc $Serverlist

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



$servers = gc $Serverlist

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
        $servers = gc $Serverlist

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
        $Servers | ForEach-Object { Get-MailboxDatabaseCopyStatus -Server $_ ; echo "---------------------------------------------------------------------------------------------------------------------------" } >> D:\checkouts\out\DBstatus.txt
    }
}

Write-Host "                    Output Log files are located at the location D:\Checkouts\Out"-ForegroundColor Cyan
echo " "
echo " "
echo " "