param(
    [string]$InputTemplatePath,
    [string]$OutputTemplatePath
)

# Read the input ARM template
$armTemplate = Get-Content -Path $InputTemplatePath -Raw | ConvertFrom-Json

# Function to find CSE sections
function Find-CSESections {
    param($resources)
    $resources | ForEach-Object {
        if ($_.type -like 'Microsoft.Compute/virtualMachines/extensions' -and ($_.properties.type -eq 'CustomScript' -or $_.properties.type -eq 'CustomScriptExtension')) {
            $_
        } elseif ($_.resources) {
            Find-CSESections -resources $_.resources
        }
    }
}

# Find all CSE (Custom Script Extension) sections
$cseSections = Find-CSESections -resources $armTemplate.resources

if (-not $cseSections -or $cseSections.Count -eq 0) {
    Write-Error "No Custom Script Extensions found in the template."
    exit 1
}

# Process the first CSE section
$cseSection = $cseSections | Select-Object -First 1
$fileUris = $cseSection.properties.protectedSettings.fileUris
$commandToExecute = $cseSection.properties.settings.commandToExecute

if (-not $fileUris -or -not $commandToExecute) {
    Write-Error "CSE section does not contain required fileUris or commandToExecute."
    exit 1
}

# Ensure parameters with quotes are properly escaped
$escapedCommand = $commandToExecute -replace '"', '""'

# Generate a one-liner script for runCommands
$downloadAndExecuteScript = @"
$fileUris | ForEach-Object { Invoke-WebRequest -Uri `"$_`" -OutFile (Split-Path -Leaf $_) }
& { $escapedCommand }
"@

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

# Remove all CSE sections from the resources
function Remove-CSESections {
    param($resources)
    $resources | ForEach-Object {
        if ($_.type -like 'Microsoft.Compute/virtualMachines/extensions' -and ($_.properties.type -eq 'CustomScript' -or $_.properties.type -eq 'CustomScriptExtension')) {
            $null
        } elseif ($_.resources) {
            $_.resources = Remove-CSESections -resources $_.resources
            $_
        } else {
            $_
        }
    }
}
$armTemplate.resources = Remove-CSESections -resources $armTemplate.resources

# Add the new runCommands resource
$armTemplate.resources += $runCommandResource

# Output the modified ARM template
$armTemplate | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputTemplatePath
