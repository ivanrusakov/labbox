Param(
    [Parameter(Mandatory=$true)]
    [string]$InputTemplatePath,

    [Parameter(Mandatory=$true)]
    [string]$OutputTemplatePath
)

# Load ARM template
$armContent = Get-Content $InputTemplatePath -Raw
$arm = $armContent | ConvertFrom-Json -Depth 100

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

if (-not $fileUris -or -not $command) {
    Write-Error "fileUris or commandToExecute not found in CSE."
    exit
}

# Generate one-liner script
$downloads = $fileUris | ForEach-Object {
    $file = [System.IO.Path]::GetFileName($_)
    "Invoke-WebRequest -Uri `"$($_)`" -OutFile `"$env:TEMP\$file`""
}
$oneLiner = ($downloads + $command) -join "; "

# Create Run Command resource
$runCmd = @{
    type = "Microsoft.Compute/virtualMachines/runCommands"
    apiVersion = "2021-07-01"
    name = "$($vm.name)/RunCustomScript"
    location = $vm.location
    properties = @{
        runCommandName = "RunCustomScript"
        source = @{
            script = $oneLiner
        }
        asyncExecution = $false
    }
}

# Remove CSE from VM's nested resources
$vm.resources = $vm.resources | Where-Object { $_.name -ne $cse.name }

# Add Run Command to top-level resources
$arm.resources += $runCmd

# Output new template with proper formatting
$arm | ConvertTo-Json -Depth 100 -Compress:$false | Set-Content $OutputTemplatePath -Encoding UTF8
