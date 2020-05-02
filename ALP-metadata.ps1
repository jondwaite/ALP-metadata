# ALP-metadata.ps1
# Create / assign metadata entries for vAppTemplates in VMware App Launchpad
# Version: 1.0, May 2nd 2020
# License: MIT
# Copyright 2020 Jon Waite, All Rights Reserved

# Helper function to create MetadataEntry structure
Function Create-MetadataEntry {
    Param(
        [parameter(Mandatory=$true)][String]$MDKey,
        [parameter(Mandatory=$true)][String]$MDValue
    )

    $MetadataEntry = New-Object VMware.VimAutomation.Cloud.Views.MetadataEntry
    $MetadataEntry.Domain = New-Object VMware.VimAutomation.Cloud.Views.MetadataDomainTag
    $MetadataEntry.Domain.Value = 'SYSTEM'
    $MetadataEntry.Domain.Visibility = 'READONLY'
    $MetadataEntry.Key = $MDKey
    $MetadataEntry.TypedValue = New-Object VMware.VimAutomation.Cloud.Views.MetadataStringValue
    $MetadataEntry.TypedValue.Value = $MDValue
    return $MetadataEntry
}

# Function to update/assign metadata to vAppTemplate object
Function Create-ALPMetadata {
    param(
        [string]$Name,
        [string]$Summary,
        [string]$Description,
        [string]$Version,
        [URI]$LogoURI,
        [URI]$ScreenShotsURI,
        [string]$OS,
        [string]$spec
    )
    $Metadata = New-Object VMware.VimAutomation.Cloud.Views.Metadata                            
    if ($Name)              { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'name' -MDValue $Name }
    if ($Summary)           { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'summary' -MDValue $Summary }
    if ($Description)       { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'description' -MDValue $Description }
    if ($Version)           { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'version' -MDValue $Version }
    if ($LogoURI)           { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'logo' -MDValue ($LogoURI.AbsoluteUri) }
    if ($ScreenShotsURI)    { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'screenshots' -MDValue ($ScreenShotsURI.AbsoluteUri) }
    if ($OS)                { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'os' -MDValue ($OS) }
    return $Metadata
}

# Main process - read JSON file with metadata entries and loop through each assigning
# metadata to each record

$vCDCatalog = 'App Launchpad Catalog'
$vCDOrg = 'AppLaucnhpad'
$JSONfile = 'ALP-metadata.json'

$mdjson = Get-Content .\Documents\ALP-metadata.json | ConvertFrom-Json

$vCDCatalogObj = Get-Catalog -Name $vCDCatalog -Org $vCDOrg
$mdjson | ForEach-Object {
    Write-Host ("Processing metadata for $($_.vAppTemplate)")
    $vAppTemplate = Get-CIVAppTemplate -Catalog $vCDCatalogObj -Name $_.vAppTemplate
    $md = Create-ALPMetadata -Name $_.name -Summary $_.Summary -Description $_.Description -Version $_.version -LogoURI $_.logo -ScreenShotsURI $_.screenshots -OS $_.os
    $vAppTemplate.ExtensionData.CreateMetadata($md)
}
Write-Host("Ended processing.")
