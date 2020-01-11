$DelFiles = gc D:\Checkouts\DelList.md

foreach($file in $DelFiles)
{
    if(Test-Path $file)
    {
        Remove-Item $file
    }
}

echo "=========================================================================================================="
echo " "
echo " If you got any errors until now you can ignore, Take care of errors from now if you get any"
echo "Here in Console, Only errors will be displayed. you can view output files in output folder"
echo " "
echo "=========================================================================================================="

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
