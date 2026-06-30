#!/usr/bin/env bash
set -euo pipefail

required_files=(
 "app/app.sh"
 "app/index.html"
 "docker/Dockerfile"
 "terraform/main.tf"
 "ansible/playbook.yml"
 "k8s/deployment.yaml"
 "k8s/service.yaml"
)

echo "[INFO] Validando estructura del framework..."
for file in "${required_files[@]}";do
 if [[ -f "$file" ]];then
   echo "[OK] $file"
 else
   echo "[ERROR] Falta $file"
   exit 1
  fi
 done

echo "[INFO] Validando sintaxis shell..."
bash -n app/app.sh
bash -n scripts/install-tools.sh
echo "[OK] Validación completada"
