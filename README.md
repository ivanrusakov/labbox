# CPU Stress Test Project
**version 1.2 beta**

This project is designed to stress-test the CPU of any Windows system and includes a template for deploying an Azure virtual machine (VM) and automatically running a deployment script. The project contains several scripts and configuration files to streamline deployment and manage the stress test. This is exquisite vintage-ish craftwork, with no modern technology involved 😉

## Quick deployment

[![Default Deployment](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fivanrusakov%2Flabbox%2Fmain%2Fcpu_stress.json)

## Project Files
- **`deploy.cmd`**: Batch script to automate the deployment process.
- **`execute.ps1`**: Staring script configured within ARM template, which deploying 
- **`cpu_stress.json`**: Azure Resource Manager (ARM) template to deploy the VM and necessary resources.
- **`cpu_stress.cfg`**: Configuration file listing the files (one by line) to be installed by `install_task.cmd`.
- **`cpu_stress.cmd`**: Batch script to start multiple instances (one per core) of the CPU stress test `cpu_stress.vbs`. `⚠️ Use with caution ⚠️`.
- **`cpu_stress.vbs`**: VBScript to create an infinite loop, simulating CPU load, single threaded.
- **`install_task.cmd`**: Batch script creates a scheduled task to run the stress test on VM startup.
- **`cleanup.cmd`**: Deletes all files in current folder except itself.  `⚠️ Use with caution ⚠️`.
- **`date_add.vbs`**: Helper script calculating date in future. Can be used with `schtasks` to configure task to run in later.
- **`run_wait.cmd`**: Helper script to run any command with timeout.

## How to Use
**Metod 1:** Run manually
- **Option 1**: Clone the repository:
  
   ```sh
    git clone --depth 1 <repository-url>
    # ... or update existing copy:
    cd <existing-repo-directory>
    git fetch --depth 1
    git reset --hard origin/master
   ```
- **Option 2**: Use PS script to download directly to target system:

   ``` powershell 
   # List of URLs to download
   $urls = @(
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/cpu_stress.cmd",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/cpu_stress.vbs",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/cpu_stress.cfg",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/install_task.cmd",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/deploy.cmd",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/cleanup.cmd",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/date_add.vbs",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/execute.ps1",
   "https://raw.githubusercontent.com/ivanrusakov/labbox/main/run_wait.cmd"
   )

   # Download each file and overwrite if it exists
   foreach ($url in $urls) {
      $fileName = [System.IO.Path]::GetFileName($url)
      $outputPath = Join-Path -Path (Get-Location) -ChildPath $fileName
      Invoke-WebRequest -Uri $url -OutFile $outputPath
   }

   Write-Output "Files downloaded and overwritten successfully."
   ```
   Execute either `deploy.cmd` or `cpu_stress.cmd` depending on your preferences.

**Method 2:** Deploy with VM from template

   Use the `cpu_stress.json` ARM template to deploy the VM and necessary resources. This can be done via the Azure portal or using Azure CLI:
   ```sh
   az deployment group create --resource-group <resource-group-name> --template-file cpu_stress.json
   ```
Also, you can use button in [quick deployment](#quick-deployment) section above.

## Monitor the VM
The VM will run the stress test, and you can monitor its performance via the [Azure Portal](https://portal.azure.com/) under the *Metrics* menu or other monitoring tools.

## Notes
- Ensure you have the necessary permissions and funds to deploy resources in your Azure subscription.
- Modify the `cpu_stress.json` template parameters as needed for your environment.
- The stress test will utilize 100% of the CPU, which may impact the responsiveness of the VM. Adjust the priority in `cpu_stress.cmd` if needed or use command line arguments.

## Disclaimer
This project is provided as-is without any warranty or guarantee of any kind. Use it at your own risk. The authors are not responsible for any damage or data loss that may occur as a result of using this project. Ensure you understand the implications of running a CPU stress test and deploying resources in your Azure subscription before proceeding.

## License

This project is licensed under the MIT License. You are free to use, modify, and distribute this project, provided that you include a reference to the original author.

## TODO
- [ ] Make install_task usable for scheduled tasks with options to run on startup, at logon and at the specific time.
- [x] Hide deployment output with nul in ARM template

## Author and Feedback

© 2023-∞ Ivan Rusakov. All rights reserved.

[![Report an Issue](https://img.shields.io/github/issues-raw/ivanrusakov/labbox?style=flat-square&logo=github&color=ff69b4)](https://github.com/ivanrusakov/labbox/issues)