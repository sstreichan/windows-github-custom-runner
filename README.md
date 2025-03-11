# 🏃 Windows Github Custom Runner 

Explore an innovative, efficient, and cost-effective approach to deploying a custom GitHub Runner that runs in a containerized Windows OS (x64) environment on a Linux system. This project leverages the robust capabilities of Vagrant VM, libvirt, and docker-compose which allows for seamless management of a Windows instance just like any Docker container. The added value here lies in the creation of a plug-and-play solution, significantly enhancing convenience, optimizing resource allocation, and integrating flawlessly with existing workflows. This strategy enriches CI/CD pipeline experiences in various dev-ops environments, providing a smooth and comprehensive approach that does not require prior knowledge of VM creation. 

⭐ **Don't forget to star the project if it helped you!**

## 📋 Prerequisites

Ensure your system meets the following requirements:

- **Docker:** Version 20 or higher [(Install Docker)](https://www.docker.com/)

- **Host OS:** Linux

- **Virtualization Enabled:**
  - Check with:
    - `grep -E -o 'vmx|svm' /proc/cpuinfo`
  - Output indicates:
    - `vmx` → Intel VT-x is supported & enabled.
    - `svm` → AMD-V is supported & enabled.
  - If virtualization is not enabled, enable it in the BIOS/UEFI settings.

## 🚥 Authentication for Self-Hosted Runners
For the purpose of authenticating your custom self-hosted runners, we offer two viable authentication methods:

1. Personal Access Token (`PAT`) - The Personal Access Token is a static, manually created token that provides secure access to GitHub. This offers a long-lived method of authentication (The PAT token needs Read and Write access to organization self-hosted runners).

2. Registration Token (`TOKEN`) - The Registration Token is a dynamic, short-lived token generated automatically by GitHub during the creation of a new self-hosted runner. This provides a temporary but immediate method of authentication.

> **Note:** Only one of these authentication methods is necessary. Choose the method that best fits your

## 🚀 Deployment Guide

1. Create/Update the environmental file `.env`
  - `PAT`: Personal access token from GitHub
  - `TOKEN`: Short lived Github token
  - `RUNNER_URL`: The URL of the GitHub that the runner connects to
  - `RUNNERS`: Number of runners
  - `MEMORY`: Amount of memory for the Vagrant image (in MB)
  - `CPU`: Number of CPUs for the Vagrant image
  - `DISK_SIZE`: Disk size for the Vagrant image (in GB)

### Example with PAT
```env
# Runner settings
PAT=<Your Personal access token>
RUNNER_URL=<runner url>
RUNNERS=1
# Vagrant image settings
MEMORY=8000 # 8GB
CPU=4
DISK_SIZE=100
```
### Example with TOKEN
```env
# Runner settings
TOKEN=<Your short lived acess token>
RUNNER_URL=<runner url>
RUNNERS=1
# Vagrant image settings
MEMORY=8000 # 8GB
CPU=4
DISK_SIZE=100
```
2. Create `docker-compose.yml`
```yaml
version: "3.9"

services:
  windows-github-runner-vm:
    image: docker.io/vaggeliskls/windows-github-custom-runner:latest
    platform: linux/amd64
    env_file: .env
    stdin_open: true
    tty: true
    privileged: true
    cgroup: host
    restart: always
    ports:
      - 3389:3389
      - 2222:2222
```
3. Create `docker-compose.override.yml` when you want your VM to be persistent
```yaml
services:
  windows-github-runner-vm:
    volumes:
      - libvirt_data:/var/lib/libvirt
      - vagrant_data:/root/.vagrant.d
      - vagrant_project:/app/.vagrant
      - libvirt_config:/etc/libvirt

volumes:
  libvirt_data:
    name: libvirt_data
  vagrant_data:
    name: vagrant_data
  vagrant_project:
    name: vagrant_project
  libvirt_config:
    name: libvirt_config
```

4. Run: `docker-compose up -d`

> When you want to destroy everything `docker compose down -v`

## 🌐 Access

### Remote Desktop (RDP)  
For debugging or testing, you can connect to the VM using **Remote Desktop** on port `3389`.  

#### Software for Remote Desktop Access  
| OS       | Software |
|----------|----------------|
| **Linux**   | [`rdesktop`](https://github.com/rdesktop/rdesktop) → `rdesktop <ip>:3389` or [`Remmina`](https://remmina.org/) |
| **MacOS**   | [Microsoft Remote Desktop](https://apps.apple.com/us/app/microsoft-remote-desktop/id1295203466?mt=12) |
| **Windows** | Built-in **Remote Desktop Connection** |

---

### SSH   
You can connect via SSH using either the **administrator** or **Vagrant** user credentials.  
```bash
ssh <user>@<host> -p 2222
```


## 🔑 User Login
The default users based on vagrant image are 

1. Administrator
    - Username: Administrator
    - Password: vagrant
1. User
    - Username: vagrant
    - Password: vagrant



## 📚 Further Reading and Resources

- [Windows in docker container](https://github.com/vaggeliskls/windows-in-docker-container)
- [Windows Vagrant Tutorial](https://github.com/SecurityWeekly/vulhub-lab)
- [Vagrant image: peru/windows-server-2022-standard-x64-eval](https://app.vagrantup.com/peru/boxes/windows-server-2022-standard-x64-eval)
- [Vagrant by HashiCorp](https://www.vagrantup.com/)
- [Windows Virtual Machine in a Linux Docker Container](https://medium.com/axon-technologies/installing-a-windows-virtual-machine-in-a-linux-docker-container-c78e4c3f9ba1)
