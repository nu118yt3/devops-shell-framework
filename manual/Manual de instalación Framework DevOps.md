
**Framework inicial DevOps en una maquina virtual Linux**

**Objetivo general**: que el alumno prepare un mini framework DevOps con Shell, Git, GitHub Actions o Jenkins, Terraform, Ansible, Docker y Kubernetes local usando una sola VM Linux.

---
### Prerrequisitos

- VirtualBox 7.2.10
- Ubuntu Server 26.04
- vCPU 4
- vRAM 8GB
- Almacenamiento 20GB
- Cuenta de GitHub
- Repositorio en blanco creado en GitHub

---
### 1. Preparación inicial de la VM

**1.1** - Validar el sistema operativo
```
uname -a
cat /etc/os-release
whoami
sudo -v
```
**1.2** - Crear carpeta del laboratorio

```
mkdir -p ~/labs 
cd ~/labs
mkdir devops-shell-framework
cd devops-shell-framework
```
---
### 2. Shell Scripting: crear el framework inicial

**2.1** - Crear estructura de carpetas
```
mkdir -p app scripts terraform ansible docker k8s .github/workflows 
touch README.md .gitignore
```
> [!NOTE]
> Ejecutar los siguientes comandos a nivel de carpeta devops-shell-framework

**2.2** - Crear script de instalación básica
```
cat > scripts/install-tools.sh <<'EOF' 
#!/usr/bin/env bash 
set -euo pipefail 
echo "[INFO] Actualizando paquetes..." 
sudo apt-get update -y echo 
"[INFO] Instalando utilerias base..." 
sudo apt-get install -y git curl wget unzip ca-certificates gnupg lsb-release software-properties-common 
echo "[INFO] Instalando Docker..." 
sudo apt-get install -y docker.io 
sudo systemctl enable --now docker 
sudo usermod -aG docker "$USER" || true 
echo "[INFO] Instalando Ansible..." 
sudo apt-get install -y ansible 
echo "[INFO] Instalando Terraform desde repositorio HashiCorp..." wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list 
sudo apt-get update -y 
sudo apt-get install -y terraform 
echo "[INFO] Instalando kubectl..." 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl rm -f kubectl 
echo "[INFO] Instalando minikube..." 
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 
sudo install minikube-linux-amd64 /usr/local/bin/minikube 
rm -f minikube-linux-amd64 
echo "[OK] Herramientas instaladas. Cierra y abre sesion para usar Docker sin sudo." 
EOF
```
>[!NOTE]
>Asegurarse que el adaptador de red de la VM se encuentre en NAT.
En VirtualBox Configuración > Red > Adaptador > Conectar a > NAT
```
chmod +x scripts/install-tools.sh
```
**2.3** - Ejecutar Script de instalación

```
./scripts/install-tools.sh
```
**2.4** - Crear mini aplicación con Shell

```
cat > app/app.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
APP_NAME="DevOps Shell Framework"
HOSTNAME_VALUE=$(hostname)
DATE_VALUE=$(date '+%Y-%m-%d %H:%M:%S')
USER_VALUE=$(whoami) 

cat > app/index.html << HTML
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>${APP_NAME}</title>
</head>
<body>
<h1>${APP_NAME}</h1>
<p>Generado por Shell Scripting</p>
<ul>
<li>Servidor: ${HOSTNAME_VALUE}</li>
<li>Usuario: ${USER_VAUE}</li>
<li>Fecha: ${DATE_VALUE}</li>
</ul>
</body>
</html>
HTML 
echo "[OK] Archivo app/index.html generado" EOF
```

Cambiar permisos al script
```
chmod +x app/app.sh
```
Ejecutar el Script
```
./app/app.sh
```
Mostrar el contenido del archivo generado
```
cat app/index.html
```
**2.5** - Crear validador de proyecto

```
cat > scripts/validate.sh <<'EOF'
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
for file in "${required_files[@]}"; do
 if [[ -f "$file" ]]; then
  echo "[OK] $file"
 else 
   echo "[ERROR] Falta $file"
    exit 1 
     fi
done 
echo "[INFO] Validando sintaxis shell..." 
bash -n app/app.sh 
bash -n scripts/install-tools.sh
echo "[OK] Validacion completada"
EOF
```
Cambiar permisos al script
```
chmod +x scripts/validate.sh
```
---
### 3. Git: Versionar el framework

**3.1** - Crear .gitignore y README
```
cat > .gitignore <<'EOF'
.terraform/ 
*.tfstate 
*.tfstate.*
*.log
.DS_Store 
EOF
```
```
cat > README.md <<'EOF'
# DevOps Shell Framework Practica sencilla de 1 dia para preparar un framework inicial DevOps usando: Shell Scripting, Git, CI/CD, Terraform, Ansible, Docker y Kubernetes. 
## Ejecucion local 
\```bash 
./app/app.sh
\```
EOF
```

**3.2** - Inicializar Repositorio
```
git init
git config user.name "Alumno DevOps"
git config user.email "alumno@example.com"
git status
git add .
git commit -m "chore: framework inicial devops"
git log --oneline
```
**3.3** - Crear rama de trabajo
```
git checkout -b feature/app-shell
# modificar README.md agregando una linea
echo "Practica ejecutada en una VM Linux." >> README.md
git add README.md
git commit -m "docs: agrega nota de ejecucion en VM"
git checkout main || git checkout master
git merge feature/app-shell
```
**3.4** - Subir repositorio local a GitHub
```
git remote add origin https://github.com/<usuario>/<nombre_repositorio.git>
git branch -M main
git config --global credential.helper store
git push -u origin main
```
>[!IMPORTANT]
Debes tener tu token de GitHub ya generado y almacenado.
Éste token es la contraseña, no la que se configuró para la cuenta

---
### 4. CI/CD: GitHub Actions

**4.1** - Creación de archivo yml con flujo de GitHub Actions
```
cat > .github/workflows/ci.yml <<'EOF'
name: CI DevOps Shell Framework
on:
 push:
  branches: [ "main", "master" ]
 pull_request:
  
jobs: 
  validate:
   runs-on: ubuntu-latest
   steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Validar scripts shell
      run: | 
       bash -n app/app.sh
       bash -n scripts/validate.sh
       
    - name: Generar HTML 
      run: | 
       ./app/app.sh
       test -f app/index.html
       
    - name: Construir imagen Docker
      run: | 
       docker build -t devops-shell-framework:ci -f docker/Dockerfile .
EOF
```
Agregar cambios y commit de archivo a Git
```
git add .github/workflows/ci.yml
git commit -m "ci: agrega pipeline github actions"
git push
```
[!NOTE]
El pipeline de GitHub fallará en el apartado de crear la imagen Docker ya que hasta este paso no ha sido creada

---
### 5. Infrastructure as Code con Terraform

**5.1** - Crear main.tf
```
cat > terraform/main.tf <<'EOF'
terraform { 
 required_version = ">= 1.0.0"
 required_providers { 
  local = { 
   source = "hashicorp/local" 
   version = "~> 2.5" 
   } 
  } 
} 

resource "local_file" "framework_info" { 
 filename = "${path.module}/framework-info.txt" 
 content = "Framework DevOps inicial creado con Terraform en laboratorio local." 
} 
EOF
```
**5.2** - Ejecutar Terraform
```
cd terraform 
terraform init
terraform fmt 
terraform validate 
terraform plan 
terraform apply -auto-approve 
cat framework-info.txt 
cd ..
```
**5.3** - Subir cambios a GitHub
```
git add .
git commit -m "feat: agrega terraform files"
git push
```

---
### 6. Configuration Management con Ansible

**6.1** - Crear inventario
```
cat > ansible/inventory.ini <<'EOF'
[local]
localhost ansible_connection=local
EOF
```
**6.2** - Crear playbook
```
cat > ansible/playbook.yml <<'EOF'
---
- name: Configuracion local para practica DevOps
  hosts: local
  become: true 
  tasks:
   - name: Instalar paquetes base
     apt:
      name:
       - curl 
       - git 
       - nginx 
      state: present 
      update_cache: true
      
   - name: Crear carpeta de publicacion demo
     file: 
      path: /opt/devops-shell-framework 
      state: directory 
      mode: '0755' 
      
   - name: Copiar pagina generada por shell 
     copy: 
      src: ../app/index.html 
      dest: /opt/devops-shell-framework/index.html 
      mode: '0644' 
EOF
```
**6.3** - Ejecutar Ansible
```
ansible --version 
ansible-inventory -i ansible/inventory.ini --list
sudo visudo
# al final del archivo agrega tu usuario con lo siguiente
<usuario> ALL=(ALL) NOPASSWD:ALL
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml 
ls -l /opt/devops-shell-framework/
```
**6.4** - Subir cambios a GitHub
```
git add .
git commit -m "feat: agrega ansible files"
git push
```
---
### 7. Containers con Docker

**7.1** - Crear Dockerfile
```
cat > docker/Dockerfile <<'EOF'
FROM nginx:alpine
COPY app/index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```
**7.2** - Construir y probar imagen
```
./app/app.sh
docker build -t devops-shell-framework:v1 -f docker/Dockerfile . docker image ls | grep devops-shell-framework

docker run -d --name devops-web -p 8081:80 devops-shell-framework:v1 
curl http://localhost:8081
 
docker stop devops-web
docker rm devops-web
```
**7.3** - Subir cambios a GitHub
```
git add .
git commit -m "feat: agrega docker files"
git push
```

---
### 8. Kubernetes local

**8.1** - Iniciar minikube
```
minikube start --driver=docker 
kubectl get nodes
```
**8.2** - Construir imagen dentro del ambiente de minikube
```
eval $(minikube docker-env) 
docker build -t devops-shell-framework:v1 -f docker/Dockerfile . docker images | grep devops-shell-framework
```
**8.3** - Crear manifiestos Kubernetes
```
cat > k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1 
kind: Deployment 
metadata: 
 name: devops-shell-framework 
spec: 
 replicas: 1 
 selector: 
  matchLabels: 
   app: devops-shell-framework 
 template: 
  metadata: 
   labels: 
    app: devops-shell-framework 
  spec: 
   containers: 
    - name: web 
      image: devops-shell-framework:v1 
      imagePullPolicy: Never 
      ports: 
       - containerPort: 80
EOF
```
```
cat > k8s/service.yaml <<'EOF'
apiVersion: v1 
kind: Service 
metadata:
 name: devops-shell-framework-svc 
spec: 
 type: NodePort
 selector: 
  app: devops-shell-framework 
 ports: 
  - port: 80 
    targetPort: 80 
    nodePort: 30080 
EOF
```
**8.4** - Desplegar y validar
```
kubectl apply -f k8s/deployment.yaml 
kubectl apply -f k8s/service.yaml 
kubectl get pods
kubectl get svc 
kubectl describe deployment devops-shell-framework 
minikube service devops-shell-framework-svc --url 
# En otra terminal o usando la URL generada: 
curl $(minikube service devops-shell-framework-svc --url)
```

**8.5** - Subir cambios a GitHub
```
git add .
git commit -m "feat: agrega K8s files"
git push
```
---
### 9. Validación integral del framework

**9.1** - Ejecutar validador
```
./scripts/validate.sh
```
**9.2** - Registrar cambios finales en Git
```
git status 
git add . 
git commit -m "feat: agrega framework devops completo"
git push 
git log --oneline --graph --all
```
---

>[!CAUTION]
Los siguientes comandos eliminan cluster y contenedores al igual que imagen de contenedor
### Comandos de limpieza
**Eliminar cluster K8s**
```
kubectl delete -f k8s/service.yaml || true 
kubectl delete -f k8s/deployment.yaml || true 
minikube stop || true
```
**Eliminar contenedor e imagen**
```
docker rm -f devops-web 2>/dev/null || true 
docker rmi devops-shell-framework:v1 2>/dev/null || true
```
**Eliminar  recursos Terraform**
```
cd terraform
terraform destroy -auto-approve || true
cd ..
```

Equipo:
@roldan0794
@antonietaGC
@castilloherreraana-sketch
@nu118yt3