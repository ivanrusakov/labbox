# CPU Stress Test Project

This project is designed to stress test the CPU of a virtual machine (VM) by running a script that utilizes 100% of the CPU. The project includes several scripts and configuration files to automate the deployment and execution of the stress test.

## Project Files
- **`cpu_stress.cfg`**: Configuration file listing the scripts to be used.
- **`cpu_stress.cmd`**: Batch script to start multiple instances of the CPU stress test.
- **`cpu_stress.json`**: Azure Resource Manager (ARM) template to deploy the VM and necessary resources.
- **`cpu_stress.vbs`**: VBScript to create an infinite loop, simulating CPU load.
- **`f.cmd`**: Batch script to fetch and reset the repository to the latest state.
- **`install_task.cmd`**: Batch script to install the necessary files and create a scheduled task to run the stress test on VM startup.

## How to Use
1. **Clone the Repository**:
   ```sh
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Fetch and Reset Repository**:
   Run the `f.cmd` script to fetch the latest changes and reset the repository:
   ```sh
   f.cmd
   ```

3. **Deploy the VM**:
   Use the `cpu_stress.json` ARM template to deploy the VM and necessary resources. This can be done via the Azure portal or using Azure CLI:
   ```sh
   az deployment group create --resource-group <resource-group-name> --template-file cpu_stress.json
   ```

4. **Install and Run the Stress Test**:
   The `install_task.cmd` script will copy the necessary files to the VM and create a scheduled task to run the stress test on startup:
   ```sh
   install_task.cmd "CPU Stress Test" "cpu_stress.cmd"
   ```

5. **Monitor the VM**:
   The VM will run the stress test, and you can monitor its performance via the Azure portal or other monitoring tools.

## Notes
- Ensure you have the necessary permissions to deploy resources in your Azure subscription.
- Modify the `cpu_stress.json` template parameters as needed for your environment.
- The stress test will utilize 100% of the CPU, which may impact the responsiveness of the VM. Adjust the priority in `cpu_stress.cmd` if needed.
