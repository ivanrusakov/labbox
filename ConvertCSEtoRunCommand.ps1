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

# Find VM resource
$vm = $arm.resources | Where-Object { $_.type -eq "Microsoft.Compute/virtualMachines" } | Select-Object -First 1

if (-not $vm) {
    Write-Error "Virtual Machine resource not found."
    exit
}

# Find CSE within VM's nested resources
$cse = $vm.resources | Where-Object { 
    $_.type -eq "extensions" -and 
    $_.properties.type -eq "CustomScriptExtension"
} | Select-Object -First 1

if (-not $cse) {
    Write-Error "Custom Script Extension not found."
    exit
}

# Extract fileUris from protectedSettings and commandToExecute from settings
$fileUris = $cse.properties.protectedSettings.fileUris
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
    name = "$($vm.name)/RunCustomScript"
    location = $arm.parameters.location.value
    properties = @{
        runCommandName = "RunCustomScript"
        source = @{
            script = "$escapedOneLiner"
        }
        asyncExecution = $false
    }
}

# Remove CSE from VM's nested resources
$vm.resources = $vm.resources | Where-Object { $_.name -ne $cse.name }

# Add Run Command to top-level resources
$arm.resources += $runCmd

# Output new template with proper formatting
$arm | ConvertTo-Json -Depth 100 | Set-Content $OutputTemplatePath -Encoding UTF8
