## Requires the SFB Online PowerShell module be installed in order to run.
## https://www.microsoft.com/en-us/download/details.aspx?id=39366

## Gets all SFB Online (Teams) users that don't have a toll free number listed in their ACP.
## Exports the users UPN to a CSV file
## Modify the $outpath before running if needed.

$outpath = C:\tmp\UsersWithoutTollFreeNumbers.csv

Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession

$users = Get-CsOnlineUser
foreach($user in $users){

    $userAcp = $user | Select -ExpandProperty ACPInfo
            if($userAcp -like "*<tollFreeNumber>*")
            {
            }
            else{
		            $upn = $user | Select -ExpandProperty userprincipalname
                $upn | Out-file $outpath -Append
            }
}
