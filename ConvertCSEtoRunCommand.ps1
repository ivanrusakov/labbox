param(
    [string]$InputTemplatePath,
    [string]$OutputTemplatePath
)

# Read the input ARM template
$armTemplate = Get-Content -Path $InputTemplatePath -Raw | ConvertFrom-Json

# Find the first CSE (Custom Script Extension) section
$cseSection = $armTemplate.resources | Where-Object {
    $_.type -like 'Microsoft.Compute/virtualMachines/extensions' -and $_.properties.publisher -eq 'Microsoft.Azure.Extensions' -and $_.properties.type -eq 'CustomScript'
} | Select-Object -First 1

if (-not $cseSection) {
    Write-Error "No Custom Script Extension found in the template."
    exit 1
}

$fileUris = $cseSection.properties.settings.fileUris
$commandToExecute = $cseSection.properties.settings.commandToExecute

if (-not $fileUris -or -not $commandToExecute) {
    Write-Error "CSE section does not contain required fileUris or commandToExecute."
    exit 1
}

# Generate a one-liner script for runCommands
$downloadAndExecuteScript = (
    "$fileUris | ForEach-Object { Invoke-WebRequest -Uri $_ -OutFile (Split-Path -Leaf $_) }; & { $commandToExecute }"
)

# Create a new runCommands resource
$runCommandResource = [PSCustomObject]@{
    type       = 'Microsoft.Compute/virtualMachines/runCommands'
    apiVersion = '2022-07-01'
    location   = $armTemplate.location
    properties = @{
        source = @{
            script = $downloadAndExecuteScript
        }
        parameters = @()
    }
}

# Remove the CSE section from the resources
$armTemplate.resources = $armTemplate.resources | Where-Object {
    !($_.type -like 'Microsoft.Compute/virtualMachines/extensions' -and $_.properties.type -eq 'CustomScript')
}

# Add the new runCommands resource
$armTemplate.resources += $runCommandResource

# Output the modified ARM template
$armTemplate | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputTemplatePath
