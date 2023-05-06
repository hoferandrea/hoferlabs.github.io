"####################################################################################################################################"
"# hoferlabs.ch                                                                                                                     #"
"# assign Graph application permissions using Graph Powershell Module                                                               #"
"# Version: 0.1                                                                                                                     #"
"# Inspired by https://jannikreinhard.com/2023/04/09/how-to-start-with-azure-automation-runbook-to-automate-tasks-in-intune/ and    #"
"# https://azurecloudai.blog/2023/03/22/azure-ad-powershell-to-microsoft-graph-powershell/                                          #"
"####################################################################################################################################"

# edit here
# for enteprise applications / managed identitites: use the object id of the enterprise application
$strAppId = "c2280552-0c9a-43e7-8f44-e862d30c8058"
$arrPermissions = "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "GroupMember.ReadWrite.All", "RoleManagement.ReadWrite.Directory" 

# do not edit
$strGraphAppId = "00000003-0000-0000-c000-000000000000"

Connect-MgGraph -Scopes Application.Read.All, AppRoleAssignment.ReadWrite.All, RoleManagement.ReadWrite.Directory

"get graph app..."
$objGraphApp = Get-MgServicePrincipal -Filter "AppId eq '$strGraphAppId'"

"assign permissions..."
ForEach ($strPermission in $arrPermissions) {
    " assign permission $strPermission..."
    $objRole = $objGraphApp.AppRoles | Where-Object { $_.Value -eq $strPermission }
    $objResult = New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $strAppId -PrincipalId $strAppId -ResourceId $objGraphApp.Id -AppRoleId $objRole.Id
}

"verify permissions..."
$arrRoleAssignment = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $strAppId
ForEach ($objRoleAssignment in $arrRoleAssignment) {
    $objRole = $objGraphApp.AppRoles | Where-Object { $_.Id -eq $objRoleAssignment.AppRoleId}
    " assignment for app role $($objRole.Value) was created on $($objRoleAssignment.CreatedDateTime) (ID: $($objRoleAssignment.AppRoleId))"
}