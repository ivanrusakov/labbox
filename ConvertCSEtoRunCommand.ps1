Param(
    [Parameter(Mandatory=$true)]
    [string]$InputTemplatePath,

    [Parameter(Mandatory=$true)]
    [string]$OutputTemplatePath
)

# Function to escape double quotes in strings
function Escape-Quotes {
    param (
        [string]$InputString
    )
    return $InputString -replace '"','`"'
}

# Load ARM template
$armContent = Get-Content $InputTemplatePath -Raw
$arm = $armContent | ConvertFrom-Json

# Find first CSE
$cse = $arm.resources | Where-Object { $_.type -eq "Microsoft.Compute/virtualMachines/extensions" -and $_.name -match "CustomScriptExtension" } | Select-Object -First 1

if (-not $cse) {
    Write-Error "Custom Script Extension not found."
    exit
}

# Extract fileUris and command
$fileUris = $cse.properties.settings.fileUris
$command = $cse.properties.settings.commandToExecute

# Escape quotes in command
$escapedCommand = Escape-Quotes $command

# Generate one-liner
$downloads = $fileUris | ForEach-Object {
    $file = [System.IO.Path]::GetFileName($_)
    $escapedUri = Escape-Quotes $_
    "Invoke-WebRequest -Uri `"$escapedUri`" -OutFile `"$env:TEMP\$file`""
}
$oneLiner = ($downloads + $escapedCommand) -join "; "

# Escape quotes in the one-liner script
$escapedOneLiner = Escape-Quotes $oneLiner

# Create Run Command resource
$runCmd = @{
    type = "Microsoft.Compute/virtualMachines/runCommands"
    apiVersion = "2021-07-01"
    name = "$($cse.name.Split('/')[0])/RunCustomScript"
    location = $arm.parameters.location.value
    properties = @{
        runCommandName = "RunCustomScript"
        source = @{
            script = "$escapedOneLiner"
        }
        asyncExecution = $false
    }
}

# Remove CSE and add Run Command
$arm.resources = $arm.resources | Where-Object { $_.name -ne $cse.name }
$arm.resources += $runCmd

# Output new template with proper formatting
$arm | ConvertTo-Json -Depth 100 | Set-Content $OutputTemplatePath -Encoding UTF8
