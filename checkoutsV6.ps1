#Parameters part

[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true)]
    [String]
    $list = $env:COMPUTERNAME
)


#Functions Part

#write-HostCenter function makes text to center paramenters are Message and Color (Both are Mandatory)
function Write-HostCenter { 
    param($Message, $color) 
    Write-Host ("{0}{1}" -f (' ' * (([Math]::Max(0, $Host.UI.RawUI.BufferSize.Width / 2) - [Math]::Floor($Message.Length / 2)))), $Message) -ForegroundColor $color
}

#showMenu function used to diplay the Menu for the activitess
function ShowMenu {
    Write-Host "Select one of the below Actions :: " -ForegroundColor Blue
    Write-Host "`n1. Move Databases to Partner server based on your selection"
    Write-Host "2. Move Databases to Activation Preference 2 server"
    Write-Host "2. Move Databases to Activation Preference 3 server"
    Write-Host "3. Rebalance the Databases for the given Servers"
    Write-Host "5. Rebalance the Databases for the servers in given DAGs"
    Write-Host "6. Perform every Server Health Checks"
    Write-Host "6. Perform every Server Health Checks with Rebalance"
    Write-Host "7. perform particular server Health checks"
    Write-Host "Press Q to Exit" 
}

function Failover {
    write-Host "Performing Failover"
}

function Failover2{
    write-Host "Performing failover 2"
}

function Failover3{
    write-Host "Performing failover 3"
}

#main Part

Clear-Host

Write-HostCenter "Welcome to Checkouts Script"  Green
ShowMenu
Write-Host 

$selection = Read-Host "Please make a selection (1 to 7)  "

switch ($selection) {
    '1' {
        Failover
    }
    '2' {
        Failover2
    } 
    '3' {
        Failover3
    } 
    '4' {

    }
    '5' {

    }
    '6' {

    }
    '7' {

    }
    'q' {
        return
    }
}