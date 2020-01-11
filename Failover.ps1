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