# ALP-metadata.ps1
# Create / assign metadata entries for vAppTemplates in VMware App Launchpad
# Version: 1.1, May 4th 2020
# License: MIT
# Copyright 2020 Jon Waite, All Rights Reserved

param(
	[Parameter(Mandatory=$true)][String]$JSONfile,
	[String]$vCDCatalog = "App Launchpad Catalog",
	[String]$vCDOrg = "AppLaunchpad"
)

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
    if ($OS)                { $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'os' -MDValue $OS }
	if ($spec)				{ $Metadata.MetadataEntry += Create-MetadataEntry -MDKey 'spec' -MDValue $spec }
    return $Metadata
}

# Main process - read JSON file with metadata entries and loop through each assigning
# metadata to each record
$mdjson = Get-Content $JSONfile -Raw | ConvertFrom-Json
$vCDCatalogObj = Get-Catalog -Name $vCDCatalog -Org $vCDOrg

Write-Host ("Found $($mdjson.Count) entries in JSON file")

$mdjson | ForEach-Object {
    Write-Host ("Processing metadata for $($_.vAppTemplate)")
	$md = Create-ALPMetadata -Name $_.name -Summary $_.Summary -Description $_.Description -Version $_.version -LogoURI $_.logo -ScreenShotsURI $_.screenshots -OS $_.os
	$vAppName = $_.vAppTemplate
    $vAppTemplate = Get-CIVAppTemplate -Catalog $vCDCatalogObj | Where { $_.Name -eq $vAppName }
    $vAppTemplate.ExtensionData.CreateMetadata($md)
}
Write-Host("Ended processing.")
