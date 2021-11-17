if (!(Get-InstalledModule -Name AzureAD) | out-null)
{
    Install-Module AzureAD -Scope CurrentUser
}

Connect-AzureAD

$users = @"
user1
user2
user3
user4
user5
"@.Split("`r`n",[System.StringSplitOptions]::RemoveEmptyEntries) | Sort-Object -Unique

$userGroupHash = @{}
$group, $userGroups = $null
$userObjects = 

foreach ($user in $users) 
{
    $userGroups = (Get-AzureADUser -SearchString $user | Get-AzureADUserMembership | Select-Object -ExpandProperty DisplayName)
    $userGroupHash.Add($user,$userGroups)
    $allGroups += $userGroups
    
}

$allGroups = $allGroups | Sort-Object -Unique

$userArray = [System.Collections.ArrayList]@()
foreach ($user in $users)
{
    $userObj = [PSCustomObject]@{
        UID      = $user
        }
    foreach ($group in $allGroups)
    {
        $value = $null
        $value = $userGroupHash[$user].Contains($group)
        $userObj | Add-Member -MemberType NoteProperty  -Name $group -Value $value
    }
    [void]$userArray.Add($userObj)
}
$userArray | Export-Csv compareusers.csv
./compareusers.csv