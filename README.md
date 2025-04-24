# manifiestos-0311at

## Tecnologías utilizadas

- Kubernetes
- Minikube (driver Docker)
- NGINX (imagen oficial)
- Volumen local montado mediante hostPath

## Estructura del repositorio

```
manifiestos-0311at/
├── deployment.yaml
├── pv.yaml
├── pvc.yaml
└── service.yaml
```

### 1. Clonar los repositorios

```bash
mkdir ~/0311AT
cd ~/0311AT
git clone <url-del-repo-del-sitio> pagina-web-0311at
git clone <url-del-repo-de-manifiestos> manifiestos-0311at
```

### 2. Iniciar Minikube con montaje de volumen

```bash
minikube start -p 0311at --driver=docker --mount --mount-string="...../pagina-web-0311at:/mnt/web"
```
se debe completar la ubicacion la carpeta donde se hizo el git clone

### 3. Aplicar los manifiestos de Kubernetes

Desde la carpeta `manifiestos-0311at`:

```bash
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 4. Acceder al sitio web

Obtener la URL del servicio:

```bash
minikube service sitio-service --url -p 0311at
```