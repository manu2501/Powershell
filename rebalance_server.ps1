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
        echo "Move-ActiveMailboxDatabase -Identity $DB -ActivateOnServer $server"
        
    }
    else
    {
       Write-Host "$DB is already in $server" -ForegroundColor Green
    }

    echo "---------------------------------------------------------------------------------------"
  }
}

