#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Actualizando paquetes..."
sudo apt-get update -y

echo "[INFO] Instalando utilerias base..."
sudo apt-get install -y git curl wget unzip ca-certificates gnupg lsb-release software-properties-common

echo "[INFO] Instalando Docker..."
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER" || true

echo "[INFO] Instalando Ansible..."
sudo apt-get install -y ansible

echo "[INFO] Instalando Terraform desde repositorio HashiCorp..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -y
sudo apt-get install -y terraform

echo "[INFO] Instalando kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo "[INFO] Instalando minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64

echo "[OK] Herramientas instaladas. Cierra y abre sesion para usar Docker sin sudo."
