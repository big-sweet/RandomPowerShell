#Run from Exchange Management Shell
#Allows for an export directly from Exchange to ProofPoint expected format for user import via CSV file.
#https://support.proofpointessentials.com/index.php?/Knowledgebase/Article/View/106/35/steps-for-adding-users-by-csv-upload

$Mailboxes = Get-Mailbox

Foreach ($Mailbox in $Mailboxes) {
    $FirstName = (($Mailbox.DisplayName).split(" "))[0]
    $LastName = (($Mailbox.DisplayName).split(" "))[1]
    $EmailAddresses = @()
    foreach ($Address in $Mailbox.EmailAddresses) {
        $EmailAddresses += (($Address | Select -ExpandProperty AddressString))
    }
    $Aliases = $EmailAddresses -join ","
    $OutString = $FirstName + "," + $LastName + "," + $Aliases
    $OutString | Out-File -FilePath "$PSScriptRoot\ProofPointExport.csv" -Append 
}
