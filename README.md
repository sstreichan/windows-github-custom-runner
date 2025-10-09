# 🏃 Windows Github & GitLab Custom Runner

Dieses Projekt ermöglicht die parallele Nutzung von GitHub und GitLab Runner in einer Windows-VM, die per Vagrant/libvirt in einem Linux-Container läuft. Die VM kann beliebig viele Runner für beide Plattformen bereitstellen.

## 🚥 Unterstützte Plattformen

- GitHub Actions
- GitLab CI

## 📋 Voraussetzungen

- [docker](https://www.docker.com/) Version 24 oder höher
- [docker-compose](https://www.docker.com/) Version 1.18 oder höher

## 🔑 Authentifizierung

### GitHub Runner

- Personal Access Token (`PAT`) **oder** Registration Token (`TOKEN`)
- `GITHUB_RUNNER_URL` muss gesetzt sein, um den GitHub Runner zu aktivieren

### GitLab Runner

- Registration Token (`REGISTRATION_TOKEN`)
- `GITLAB_RUNNER_URL` muss gesetzt sein, um den GitLab Runner zu aktivieren

## 🚀 Deployment Guide

1. Erstellen/Anpassen der `.env` Datei:

```env
# Gemeinsame Einstellungen
RUNNER_NAME=windows_x64_vagrant
RUNNERS=1
MEMORY=4096
CPU=2
DISK_SIZE=100

# GitHub Runner Konfiguration (leer lassen, um zu deaktivieren)
GITHUB_RUNNER_URL=https://github.com/org/repo
PAT=your_personal_access_token
TOKEN=your_temporary_token

# GitLab Runner Konfiguration (leer lassen, um zu deaktivieren)
GITLAB_RUNNER_URL=https://gitlab.com/
REGISTRATION_TOKEN=your_gitlab_registration_token
```

2. `docker-compose.yml` Beispiel:

```yaml
version: "3.9"
services:
  windows-runner-vm:
    image: docker.io/vaggeliskls/windows-ci-custom-runner:latest
    build:
      dockerfile: ./Dockerfile
      context: .
    env_file: .env
    stdin_open: true
    tty: true
    privileged: true
    ports:
      - 3389:3389
```

3. Starten:

```bash
docker-compose up -d
```

## 🌐 Zugriff per Remote Desktop

- RDP-Port: 3389
- Standard-User: Administrator/vagrant oder vagrant/vagrant

## 📝 Hinweise

- Beide Runner können gleichzeitig genutzt werden, wenn beide URLs gesetzt sind
- Zum Deaktivieren eines Runners einfach die entsprechende URL leer lassen
- Die VM installiert automatisch alle nötigen Tools für beide Plattformen

## 📚 Weitere Ressourcen

- [Windows in docker container](https://github.com/vaggeliskls/windows-in-docker-container)
- [Vagrant image: peru/windows-server-2022-standard-x64-eval](https://app.vagrantup.com/peru/boxes/windows-server-2022-standard-x64-eval)
- [Vagrant by HashiCorp](https://www.vagrantup.com/)
- [Windows Virtual Machine in a Linux Docker Container](https://medium.com/axon-technologies/installing-a-windows-virtual-machine-in-a-linux-docker-container-c78e4c3f9ba1)
