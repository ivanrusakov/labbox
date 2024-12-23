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
        if ($_.properties.publisher -eq 'Microsoft.Compute' -and $_.properties.type -eq 'CustomScriptExtension') {
            $_
        } elseif ($_.resources) {
            Find-CSESections -resources $_.resources
        }
    }
}

# Find all CSE (Custom Script Extension) sections, both nested and standalone
$cseSections = Find-CSESections -resources $armTemplate.resources

if (-not $cseSections -or $cseSections.Count -eq 0) {
    Write-Error "No Custom Script Extensions found in the template."
    exit 1
}

# Process the first CSE section
$cseSection = $cseSections | Select-Object -First 1
$fileUris = if ($cseSection.properties.protectedSettings) {
    $cseSection.properties.protectedSettings.fileUris
} else {
    @()
}
$commandToExecute = $cseSection.properties.settings.commandToExecute

if (-not $commandToExecute) {
    Write-Error "CSE section does not contain required commandToExecute."
    exit 1
}

# Ensure parameters with quotes are properly escaped
$escapedCommand = $commandToExecute -replace '"', '""'

# Generate a one-liner script for runCommands
$downloadAndExecuteScript = @"
$fileUris | ForEach-Object { Invoke-WebRequest -Uri \"$_\" -OutFile (Split-Path -Leaf $_) }
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

# Remove all CSE sections from the resources, both nested and standalone
function Remove-CSESections {
    param($resources)
    $resources | ForEach-Object {
        if ($_.type -like 'Microsoft.Compute/virtualMachines/extensions' -and $_.properties.publisher -eq 'Microsoft.Compute' -and $_.properties.type -eq 'CustomScriptExtension') {
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

# Custom function for JSON serialization with encoding fixes
function ConvertTo-CustomJson {
    param (
        [Parameter(Mandatory=$true)]
        [psobject]$InputObject
    )
    $json = $InputObject | ConvertTo-Json -Depth 10 -Compress
    $json = $json -replace '\\u0027', "'" -replace '\\u0022', '"' -replace '\\u0026', '&'
    return $json
}

# Output the modified ARM template
$customJson = ConvertTo-CustomJson -InputObject $armTemplate
[System.IO.File]::WriteAllText($OutputTemplatePath, $customJson, [System.Text.Encoding]::UTF8)
