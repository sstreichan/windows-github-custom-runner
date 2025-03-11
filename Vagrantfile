Vagrant.configure("2") do |config|

    # Get values from environment variables (or set defaults)
    cpu_count = ENV["CPU"] ? ENV["CPU"].to_i : 4
    memory_size = ENV["MEMORY"] ? ENV["MEMORY"].to_i : 8000
    disk_size = ENV["DISK_SIZE"] ? ENV["DISK_SIZE"].to_i : 100
    privileged = ENV["PRIVILEGED"] ? ENV["PRIVILEGED"] == "true" : true
    interactive = ENV["INTERACTIVE"] ? ENV["INTERACTIVE"] == "true" : true

    config.vm.box = ENV["VAGRANT_BOX"] || "peru/windows-server-2022-standard-x64-eval"
    config.vm.box_check_update = false
    config.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh"   # ✅ Forward SSH
    config.vm.network "forwarded_port", guest: 80, host: 8080, id: "http"  # ✅ Forward HTTP
    config.vm.network "forwarded_port", guest: 443, host: 8443, id: "https" # ✅ Forward HTTPS
    config.vm.network "forwarded_port", guest: 3389, host: 3389, id: "rdp" # ✅ Forward RDP
    # Rsync
    # This needs the rsync to be installed on widnows box. The sync is executed before the install
    # that leads to: There was an error when attempting to rsync a synced folder.
    # config.vm.synced_folder "/app/shared", "C:/shared", type: "rsync"
    # Samba
    # Currently samba is not supported on linux hosts 
    # https://developer.hashicorp.com/vagrant/docs/synced-folders/smb
    # config.vm.synced_folder "/app/shared", "C:/shared", type: "smb"
    # NFS
    # When running nfs server in container
    # * Not starting NFS kernel daemon: no support in current kernel
    config.vm.provision "shell", inline: "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False"
    config.vm.provider "libvirt" do |libvirt|
        libvirt.driver = ENV["LIBVIRT_DRIVER"] || "kvm"
        libvirt.memory = memory_size
        libvirt.cpus = cpu_count
        libvirt.machine_virtual_size = disk_size
        libvirt.forward_ssh_port = true
    end
    
    config.winrm.max_tries = 300 # default is 20
    config.winrm.retry_delay = 5 #seconds. This is the defaul value and just here for documentation.
    config.vm.provision "shell", powershell_elevated_interactive: ${INTERACTIVE}, privileged: ${PRIVILEGED}, inline: <<-SHELL
        # Install Chocolatey - Also Grabs 7Zip
        Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -AddToPath"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco install 7zip.install git.install jq -y 
        # c:/ default location
        Set-Location /
        # Install build tools
        Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_enterprise.exe" -OutFile "vs_enterprise.exe"
        ./vs_enterprise.exe --quiet --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended # --passive
        # Install rtools40
        Invoke-WebRequest -Uri "https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe" -OutFile "rtools.exe"
        Start-Process "./rtools.exe" -Argument "/Silent" -PassThru -Wait
        [Environment]::SetEnvironmentVariable("PATH", $env:Path + ";C:\\rtools40\\usr\\bin;C:\\rtools40\\mingw64\\bin", [EnvironmentVariableTarget]::Machine)
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
        C:\\rtools40\\msys2.exe pacman -Sy --noconfirm mingw-w64-x86_64-make
        Remove-Item -Path ./rtools.exe
        # Resize disk
        Resize-Partition -DriveLetter "C" -Size (Get-PartitionSupportedSize -DriveLetter "C").SizeMax
        # Enable too long paths
        New-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
        $username = "VAGRANTVM\\vagrant"
        $password = "vagrant"
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
        # github actions
        Invoke-WebRequest -Uri ${GITHUB_RUNNER_URL} -OutFile ${GITHUB_RUNNER_FILE}
        Remove-Item -Path C:\\runner-* -Recurse -Force
        for ($runner = 1 ; $runner -le ${RUNNERS} ; $runner++){  
            Write-Host "Running  $runner";
            $random = -join ((48..57) + (97..122) | Get-Random -Count 8 | % {[char]$_});
            Expand-Archive -LiteralPath ${GITHUB_RUNNER_FILE} -DestinationPath runner-$random -Force;
            if (![string]::IsNullOrEmpty("${PAT}")) {
                Invoke-Expression -Command "C:\\runner-$random\\config.cmd --name ${GITHUB_RUNNER_NAME}_$random --replace --unattended --url ${RUNNER_URL} --labels ${GITHUB_RUNNER_LABELS} --pat ${PAT}";
            } else {
                Invoke-Expression -Command "C:\\runner-$random\\config.cmd --name ${GITHUB_RUNNER_NAME}_$random --replace --unattended --url ${RUNNER_URL} --labels ${GITHUB_RUNNER_LABELS} --token ${TOKEN}";
            }
            Start-Process "C:\\runner-$random\\run.cmd" -Credential ($credentials);
        }
    SHELL
end
  
