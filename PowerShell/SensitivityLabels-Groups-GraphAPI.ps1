# SensitivityLabels-Groups-GraphAPI.ps1
# atwork.at, Christoph Wilfing, Toni Pohl, 2024-04-22
# This script replaces AzureADPreview Method of setting the EnableMIPLabels to True
# https://learn.microsoft.com/en-us/purview/sensitivity-labels-teams-groups-sites#enable-this-preview-and-synchronize-labels
# https://learn.microsoft.com/en-us/entra/identity/users/groups-assign-sensitivity-labels

# Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
# Update-Module Microsoft.Graph.Authentication
# Install-Module Microsoft.Graph.Beta.Identity.DirectoryManagement -Scope CurrentUser
# Update-Module Microsoft.Graph.Beta.Identity.DirectoryManagement

#Requires -Module Microsoft.Graph.Authentication
#Requires -Module Microsoft.Graph.Beta.Identity.DirectoryManagement
$TenantID = '<your-tenantid>'
$Scopes = @('Directory.ReadWrite.All')

Connect-MgGraph -Scopes $Scopes -TenantId $TenantID

$grpUnifiedSetting = Get-MgBetaDirectorySetting -Search DisplayName:"Group.Unified"

if ($Null -eq $grpUnifiedSetting) {
    Write-Host 'Missing Directory Settings - Creating new settings'
    $TemplateId = (Get-MgBetaDirectorySettingTemplate | Where-Object { $_.DisplayName -eq "Group.Unified" }).Id
    #$Template = Get-MgBetaDirectorySettingTemplate | Where-Object -Property Id -Value $TemplateId -EQ
    $params = @{
        templateId = "$TemplateId"
        Values     = @(
            @{
                Name  = "EnableMIPLabels"
                Value = "True"
            }
        )
    }    
    $grpUnifiedSetting = New-MgBetaDirectorySetting -BodyParameter $params
}
else {
    Write-Host 'Found existing settings - updating settings'
    $params = @{
        Values = @(
            @{
                Name  = "EnableMIPLabels"
                Value = "True"
            }
        )
    }
    Update-MgBetaDirectorySetting -DirectorySettingId $grpUnifiedSetting.Id -BodyParameter $params
}

# Verify the settings
$Setting = Get-MgBetaDirectorySetting -DirectorySettingId $grpUnifiedSetting.Id
$Setting.Values

# Done.
Disconnect-MgGraph
