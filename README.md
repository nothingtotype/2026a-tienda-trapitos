# 2026a-tienda-trapitos

Proyecto escolar para el desarrollo de un sistema POS (Point of Sale) para el negocio local "Trapitos". 

<img width="1905" height="2035" alt="image" src="https://github.com/user-attachments/assets/916d5b27-28a3-4787-8678-7ffd065f0b62" />


Este repositorio contiene los scripts de infraestructura y la configuración necesaria para desplegar el servidor web seguro y gestionar la carga inicial del inventario.

---

## 📋 Requisitos Previos

Para desplegar este proyecto, necesitarás preparar el siguiente entorno:

* **Sistema Operativo:** Máquina Virtual (VM) con **Rocky Linux** (versión 8 o 9).
* **Acceso:** Privilegios de administrador (`root` o mediante `sudo`).
* **Red:** Conexión a internet estable y una dirección IP configurada (preferentemente estática).
* **Dominio (Recomendado):** Un nombre de dominio apuntando a la IP de la máquina virtual para la correcta generación del certificado SSL.

---

## 📂 Estructura del Repositorio

* `/inventario/`
    * `productos_trapitos.csv`: Archivo base con los datos iniciales para importar el inventario al sistema POS.
* `/scripts/`
    * `01-setup.sh`: Script de configuración inicial del entorno, instalación de paquetes y servicios base.
    * `03-instalar-cert-ssl.sh`: Script para la generación e instalación de los certificados de seguridad SSL.
    * `04-redirect.sh`: Configuración del servidor web para enrutar el tráfico y forzar la conexión segura por el puerto 443 (HTTPS) por defecto.
* `/imagenes/`: imagenes

## 🚀 Instrucciones de Instalación y Ejecución

Una vez que la máquina virtual con Rocky Linux esté lista, sigue estos pasos para desplegar la configuración:

### 1. Clonar el Repositorio
Descarga los archivos del proyecto en tu servidor (puedes hacerlo en tu directorio de usuario o en `/opt`):

```bash
git clone https://github.com/tu-usuario/2026a-tienda-trapitos.git
cd 2026a-tienda-trapitos

```

### 2. Asignar Permisos de Ejecución

Los scripts en bash necesitan permisos explícitos para poder ejecutarse:

```bash
chmod +x scripts/*.sh

```

### 3. Ejecutar la Secuencia de Scripts

El orden de ejecución es crítico para asegurar que los servicios dependientes se levanten correctamente. Ejecuta cada uno verificando que no arroje errores antes de pasar al siguiente:

**Paso A: Preparación del entorno base**

```bash
sudo ./scripts/01-setup.sh

```

**Paso B: Instalación del Certificado SSL**
*(Nota: Asegúrate de que tu dominio esté resolviendo a la IP de esta máquina antes de ejecutar este paso)*

```bash
sudo ./scripts/03-instalar-cert-ssl.sh

```

**Paso C: Configuración de Redirección (Forzar Puerto 443)**

```bash
sudo ./scripts/04-redirect.sh

```

### 6. Instalacion de los plugins necesarios

<img width="1695" height="814" alt="HKrhN84c3y" src="https://github.com/user-attachments/assets/26f0402d-b023-4717-bd61-a0863d2e4e6a" />


### 5. Carga de Inventario

Una vez que el servidor web y el sistema POS estén en línea y asegurados por HTTPS, utiliza la interfaz del sistema para importar el archivo ubicado en:
`inventario/productos_trapitos.csv`

```

```
