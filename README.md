# CPU Stress Test Project

This project is designed to stress test the CPU of a virtual machine (VM) by running a script that utilizes 100% of the CPU. The project includes several scripts and configuration files to automate the deployment and execution of the stress test.

Quick deployment: 
[Default Deployment](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fivanrusakov%2Flabbox%2Fmain%2Fcpu_stress.json)
[No Storage Account](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fivanrusakov%2Flabbox%2Fmain%2Fcpu_stress_no_str.json)

## Project Files
- **`deploy.cmd`**: Batch script to automate the deployment process using configured in cpu_stress.json.
- **`cpu_stress.json`**: Azure Resource Manager (ARM) template to deploy the VM and necessary resources.
- **`cpu_stress.cfg`**: Configuration file listing the files to be installed.
- **`cpu_stress.cmd`**: Batch script to start multiple instances of the CPU stress test.
- **`cpu_stress.vbs`**: VBScript to create an infinite loop, simulating CPU load, one per core.
- **`install_task.cmd`**: Batch script to install the necessary files and create a scheduled task to run the stress test on VM startup.

## How to Use
1. **Clone the Repository**:
   ```sh
    git clone --depth 1 <repository-url>
    # ... or update existing copy:
    cd <existing-repo-directory>
    git fetch --depth 1
    git reset --hard origin/master
   ```

2. **Deploy the VM**:
   Use the `cpu_stress.json` ARM template to deploy the VM and necessary resources. This can be done via the Azure portal or using Azure CLI:
   ```sh
   az deployment group create --resource-group <resource-group-name> --template-file cpu_stress.json
   ```

3. **Monitor the VM**:
   The VM will run the stress test, and you can monitor its performance via the Azure portal or other monitoring tools.

## Notes
- Ensure you have the necessary permissions to deploy resources in your Azure subscription.
- Modify the `cpu_stress.json` template parameters as needed for your environment.
- The stress test will utilize 100% of the CPU, which may impact the responsiveness of the VM. Adjust the priority in `cpu_stress.cmd` if needed.
