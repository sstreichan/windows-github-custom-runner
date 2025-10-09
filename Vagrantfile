Vagrant.configure("2") do |config|

    config.vm.box = "${VAGRANT_BOX}"
    config.vm.network "private_network", ip: "192.168.121.10"
    config.vm.network "forwarded_port", guest: 445, host: 445
    config.vm.provision "shell", inline: "Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False"
    config.vm.provider "libvirt" do |libvirt|
        libvirt.memory = ${MEMORY}
        libvirt.cpus = ${CPU}
        libvirt.machine_virtual_size = ${DISK_SIZE}
        libvirt.forward_ssh_port = true
    end
    config.winrm.max_tries = 300 # default is 20
    config.winrm.retry_delay = 5 #seconds. This is the defaul value and just here for documentation.
    config.vm.provision "shell", powershell_elevated_interactive: ${INTERACTIVE}, privileged: ${PRIVILEGED}, inline: <<-SHELL
        # Install Chocolatey and basic tools
        Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -AddToPath"
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco install 7zip.install git.install jq -y 
        
        # Set default location
        Set-Location /
        
        # Install build tools
        Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_enterprise.exe" -OutFile "vs_enterprise.exe"
        ./vs_enterprise.exe --quiet --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended
        
        # Install rtools40
        Invoke-WebRequest -Uri "https://cran.r-project.org/bin/windows/Rtools/rtools40-x86_64.exe" -OutFile "rtools.exe"
        Start-Process "./rtools.exe" -Argument "/Silent" -PassThru -Wait
        [Environment]::SetEnvironmentVariable("PATH", $env:Path + ";C:\\rtools40\\usr\\bin;C:\\rtools40\\mingw64\\bin", [EnvironmentVariableTarget]::Machine)
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
        C:\\rtools40\\msys2.exe pacman -Sy --noconfirm mingw-w64-x86_64-make
        Remove-Item -Path ./rtools.exe
        
        # Resize disk and enable long paths
        Resize-Partition -DriveLetter "C" -Size (Get-PartitionSupportedSize -DriveLetter "C").SizeMax
        New-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
        
        $username = "VAGRANTVM\\vagrant"
        $password = "vagrant"
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
        
        # Install and configure runners
        
        # GitLab Runner Installation
        if ("${GITLAB_ENABLED}" -eq "true") {
            Write-Host "Installing GitLab Runner..."
            Invoke-WebRequest -Uri ${GITLAB_RUNNER_URL} -OutFile ${GITLAB_RUNNER_FILE}
            for ($runner = 1 ; $runner -le ${RUNNERS} ; $runner++) {
                $random = -join ((48..57) + (97..122) | Get-Random -Count 8 | % {[char]$_})
                $runnerPath = "C:\\gitlab-runner-$random"
                New-Item -ItemType Directory -Path $runnerPath
                Copy-Item ${GITLAB_RUNNER_FILE} -Destination "$runnerPath\\gitlab-runner.exe"
                Set-Location $runnerPath
                
                if (![string]::IsNullOrEmpty("${REGISTRATION_TOKEN}")) {
                    ./gitlab-runner.exe register `
                        --non-interactive `
                        --url "${GITLAB_RUNNER_URL}" `
                        --registration-token "${REGISTRATION_TOKEN}" `
                        --name "${RUNNER_NAME}_gitlab_$random" `
                        --tag-list "${GITLAB_RUNNER_TAGS}" `
                        --executor "shell" `
                        --shell "powershell"
                    
                    ./gitlab-runner.exe install
                    ./gitlab-runner.exe start
                }
            }
        }
        
        # GitHub Runner Installation
        if (![string]::IsNullOrEmpty("${GITHUB_RUNNER_URL}")) {
            Write-Host "Installing GitHub Runner..."
            Invoke-WebRequest -Uri ${GITHUB_RUNNER_URL} -OutFile ${GITHUB_RUNNER_FILE}
            for ($runner = 1 ; $runner -le ${RUNNERS} ; $runner++){  
                $random = -join ((48..57) + (97..122) | Get-Random -Count 8 | % {[char]$_})
                Expand-Archive -LiteralPath ${GITHUB_RUNNER_FILE} -DestinationPath runner-$random -Force
                if (![string]::IsNullOrEmpty("${PAT}")) {
                    Invoke-Expression -Command "C:\\runner-$random\\config.cmd --name ${RUNNER_NAME}_github_$random --replace --unattended --url ${GITHUB_RUNNER_URL} --labels ${GITHUB_RUNNER_LABELS} --pat ${PAT}"
                } else {
                    Invoke-Expression -Command "C:\\runner-$random\\config.cmd --name ${RUNNER_NAME}_github_$random --replace --unattended --url ${GITHUB_RUNNER_URL} --labels ${GITHUB_RUNNER_LABELS} --token ${TOKEN}"
                }
                Start-Process -FilePath "C:\\runner-$random\\run.cmd" -NoNewWindow
            }
        }
    SHELL
end