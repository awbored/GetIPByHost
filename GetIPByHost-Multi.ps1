## $input file will be your host names, just dump them in a txt document and update the location
## $output file will be where the script will dump the CSV output

$ErrorActionPreference = 'SilentlyContinue'
$input = ".\input.txt"
$output = ".\$(get-date -f yyyy-MM-dd)-HostIPResolve.csv"
$PingArray = @()


# Start timer
$scriptStartTime = $(get-date)
Write-Host "Starting Script at $scriptStartTime" -f Yellow


Get-Content $input | ForEach-Object {
    # Create an object that will have the members for each loop in the array
    $Results = New-Object psobject


    # Set common variables ie no logic
    $hostname = $_
    $ip = ([System.Net.Dns]::GetHostAddresses("$hostname")).IPAddressToString
    $fqdn = ([System.Net.Dns]::GetHostByAddress("$ip")).HostName	

    
    # Determine variables that change
    IF(Test-Connection -BufferSize 32 -Count 1 -ComputerName $hostname -Quiet){
        $status = "Online"
        Write-Host "$hostname`t$fqdn`t$ip`t$status" -f green
    }

    Else{
        $status = "Offline"
        Write-Host "$hostname`t$fqdn`t$ip`t$status" -f red
    }


    # Add common values to objects
    $Results | Add-Member -Name "HostName" -MemberType NoteProperty -Value $hostname
    $Results | Add-Member -Name "FQDN" -MemberType NoteProperty -Value $fqdn
    $Results | Add-Member -Name "IP" -MemberType NoteProperty -Value $ip
    $Results | Add-Member -Name "Status" -MemberType NoteProperty -Value $status
    
    # Add results to the array    
    $PingArray += $Results

    
	Clear-Variable ip,fqdn,hostname,status
	
    }

$PingArray | Export-Csv $output -NoTypeInformation

# End timer
$elapsedTime = $(get-date) - $scriptStartTime
write-host "`nEnding script at $(get-date).  Elapsed time is" $elapsedTime.TotalMinutes "Minutes" -f Yellow
