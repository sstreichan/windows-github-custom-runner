# GitHub Copilot - Projekt-Anweisungen

## 🏗 Architektur-Überblick

Dieses Projekt implementiert einen Windows-basierten GitHub Runner in einer Linux-Container-Umgebung durch:

1. **Container-Layer**: Docker-Container als Basis (`docker-compose.yml`)
2. **Virtualisierungs-Layer**: Vagrant/libvirt zum Betrieb der Windows-VM
3. **Windows-Layer**: Windows Server 2022 mit GitHub Runner-Installation

### Kernkomponenten

- `Dockerfile`: Basiert auf `windows-in-docker-container`, setzt Runner-Konfiguration
- `startup.sh`: Initialisiert libvirt und startet die Vagrant-VM
- `Vagrantfile`: Definiert VM-Konfiguration und Windows-Provisioning
- `.env`: Konfigurationsvariablen (Runner-Auth, VM-Ressourcen)

## 🔄 Entwicklungs-Workflows

### Build und Start

```bash
# Konfiguration in .env setzen
# Erforderlich: PAT oder TOKEN, RUNNER_URL
docker-compose up -d
```

### Debug-Zugriff

- RDP-Port: 3389
- Windows-Credentials:
  - Administrator/vagrant
  - vagrant/vagrant

## 🎯 Projekt-Konventionen

### Umgebungsvariablen
- `PAT`: Langlebiger Personal Access Token
- `TOKEN`: Kurzlebiger Registrierungs-Token
- Nur EINE Auth-Methode verwenden

### Runner-Labels
Standard-Labels im `Dockerfile`:
```
windows,win_x64,windows_x64,windows_vagrant_action
```

### VM-Ressourcen (via .env)
- `MEMORY`: RAM in MB
- `CPU`: Anzahl CPUs
- `DISK_SIZE`: Festplattengröße in GB

## 🔌 Integration

### Vorinstallierte Tools
- PowerShell Core
- Chocolatey
- Git
- Visual Studio Build Tools
- RTools40

### Netzwerk
- VM-IP: 192.168.121.10
- Exposed Ports: 
  - 3389 (RDP)
  - 445 (SMB)

## ⚠️ Wichtige Hinweise

1. Container benötigt privilegierte Rechte für libvirt
2. KVM-Zugriff muss konfiguriert sein
3. Windows-Firewall wird automatisch deaktiviert
4. Lange Pfadnamen sind aktiviert (LongPathsEnabled)