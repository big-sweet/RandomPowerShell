$ScopeName = "My DHCP Scope"
$Domain = "domain.com"

$hosts = Get-DhcpServerv4Scope | Where Name -like $ScopeName | Get-DhcpServerv4Lease | Select HostName, IPAddress
foreach ($lease in $hosts) {
    if ((Test-NetConnection $lease).PingSucceeded -eq "True") {
        $lease | Out-File "C:\temp\ActiveDHCPLeases - $ScopeName" -Append
    }
    else {
        $LastLogon = Get-ADComputer -Identity $lease.HostName.trim(".$Domain") -Properties LastLogonDate | Select LastLogonDate
        $lease + " Last Logon: $LastLogon" | Out-File "C:\temp\StaleDHCPLeases-$ScopeName.txt" -Append
    }
}
