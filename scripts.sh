#!/bin/bash

set -e

# ------------ FUNCIONES ------------

titulo() {
  echo
  echo "🔷 $1"
  echo "--------------------------------------------"
}

instalar_paquete() {
  if ! command -v "$1" &> /dev/null; then
    titulo "Instalando $1"
    sudo apt update
    sudo apt install -y "$2"
  else
    echo "✅ $1 ya está instalado"
  fi
}

# ------------ PASO 1: Verificar dependencias ------------

titulo "Verificando e instalando dependencias necesarias"

instalar_paquete git git
instalar_paquete curl curl

# Instalar Docker
if ! command -v docker &> /dev/null; then
  titulo "Instalando Docker"
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $USER
else
  echo "✅ Docker ya está instalado"
fi

# Instalar kubectl
if ! command -v kubectl &> /dev/null; then
  titulo "Instalando kubectl"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "✅ kubectl ya está instalado"
fi

# Instalar Minikube
if ! command -v minikube &> /dev/null; then
  titulo "Instalando Minikube"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
else
  echo "✅ Minikube ya está instalado"
fi

# ------------ PASO 2: Clonar los repositorios ------------

WORKDIR="$HOME/0311AT"
REPO_MANIFIESTOS="https://github.com/LucaCostabile/manifiestos-0311at.git"
REPO_WEB="https://github.com/LucaCostabile/pagina-web-0311at.git"

titulo "Creando carpeta de trabajo en $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

titulo "Clonando los repositorios"

if [ ! -d "$WORKDIR/pagina-web-0311at" ]; then
  git clone "$REPO_WEB" pagina-web-0311at
else
  echo "📂 Repositorio del sitio ya clonado"
fi

if [ ! -d "$WORKDIR/manifiestos-0311at" ]; then
  git clone "$REPO_MANIFIESTOS" manifiestos-0311at
else
  echo "📂 Repositorio de manifiestos ya clonado"
fi

# ------------ PASO 3: Iniciar Minikube ------------

titulo "Iniciando Minikube y montando sitio web"

minikube delete -p 0311at &> /dev/null || true

minikube start -p 0311at --driver=docker \
  --mount \
  --mount-string="$WORKDIR/pagina-web-0311at:/mnt/web"

# ------------ PASO 4: Aplicar manifiestos ------------

cd "$WORKDIR/manifiestos-0311at"

titulo "Aplicando manifiestos Kubernetes"

kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# ------------ PASO 5: Mostrar acceso ------------

titulo "Sitio desplegado correctamente"

echo "🌐 Dirección de acceso:"
minikube service sitio-service --url -p 0311at
echo
echo "✅ Fin del proceso"
