# ALP-metadata
PowerShell script to create/update vAppTemplate metadata for VMware App Launchpad

This script (ALP-metadata.ps1) takes an input JSON format file which defines the metadata entries to be added/updated on vAppTemplates in VMware Cloud Director App Launchpad catalogs to augment the appearance and data associated with each template. An example JSON file (ALP-metadata.json) is provided showing the keys supported and some example entries appropriate for common Bitnami published applications.

You must be connected to VMware Cloud Director (VCD) from your PowerShell session (Connect-CIServer) as an administrator in the 'System' organization for this script to run. Adjust the Organization and Catalog definitions in the script as appropriate for your environment if required.

Please feel free to use/abuse as required, or log PRs or issues if you have any problems.

Jon Waite, 2nd May 2020.
