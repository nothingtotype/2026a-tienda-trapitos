#!/bin/bash

# ==============================================================================
# Script de configuración automatizada para entorno de desarrollo WordPress
# Sistema Operativo: Rocky Linux 9
# ==============================================================================

# 1. Actualizar todas las dependencias del sistema a su última versión
echo "Actualizando los paquetes del sistema..."
dnf update -y

# 2. Instalar el servidor web (Apache) y utilidades de red
echo "Instalando Apache (httpd) y utilidades..."
dnf install httpd wget tar -y

# 3. Instalar la base de datos (MariaDB es el estándar nativo para Rocky Linux 9)
echo "Instalando el servidor de base de datos MariaDB..."
dnf install mariadb-server mariadb -y

# 4. Instalar PHP y las extensiones necesarias para WordPress y WooCommerce
# Se incluyen intl y zip, que son altamente recomendadas para tiendas en línea
echo "Instalando PHP y sus extensiones..."
dnf install php php-mysqlnd php-gd php-xml php-mbstring php-json php-intl php-zip -y

# 5. Iniciar y habilitar los servicios para que arranquen automáticamente con la VM
echo "Habilitando y arrancando servicios..."
systemctl enable --now httpd
systemctl enable --now mariadb

# 6. Configurar el Firewall para permitir el acceso desde la máquina anfitriona Windows
echo "Abriendo puertos en el firewall..."
# Permitir tráfico web estándar
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
# Permitir tráfico a la base de datos para acceder externamente desde Windows (ej. DBeaver)
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload

# 7. Configurar la base de datos para el proyecto
echo "Configurando la base de datos de WordPress..."
DB_NAME="tienda_offline"
DB_USER="dev_admin"
DB_PASS="DevPassW0rd123!" # Contraseña temporal para el entorno de desarrollo

# Crear la base de datos y el usuario
# El comodín '%' permite que este usuario se conecte desde cualquier IP externa (tu host Windows)
mysql -e "CREATE DATABASE ${DB_NAME};"
mysql -e "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Configurar MariaDB para que escuche conexiones externas y no solo en localhost
sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' /etc/my.cnf.d/mariadb-server.cnf
systemctl restart mariadb

# 8. Descargar y posicionar los archivos de WordPress
echo "Descargando la última versión de WordPress..."
wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz

# Extraer el contenido directamente en el directorio raíz de Apache
tar -xzf /tmp/wordpress.tar.gz -C /var/www/html/
# Mover los archivos un nivel arriba para que no queden en la subcarpeta '/wordpress'
mv /var/www/html/wordpress/* /var/www/html/
rm -rf /var/www/html/wordpress
rm -f /tmp/wordpress.tar.gz

# 9. Inyectar las credenciales en el archivo de configuración de WordPress
echo "Generando el archivo wp-config.php..."
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${DB_NAME}/" /var/www/html/wp-config.php
sed -i "s/username_here/${DB_USER}/" /var/www/html/wp-config.php
sed -i "s/password_here/${DB_PASS}/" /var/www/html/wp-config.php

# 10. Ajustar permisos de carpetas y políticas de SELinux
echo "Ajustando permisos de sistema y contextos de SELinux..."
# Asignar a Apache como el dueño de los archivos
chown -R apache:apache /var/www/html/
find /var/www/html/ -type d -exec chmod 755 {} \;
find /var/www/html/ -type f -exec chmod 644 {} \;

# Permitir a Apache establecer conexiones de red y acceder a la base de datos a través de SELinux
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_network_connect_db 1

# Cambiar el contexto de SELinux para que WordPress pueda escribir en disco 
# (Esencial para instalar plugins, temas y subir imágenes en tu tienda)
chcon -R -t httpd_sys_rw_content_t /var/www/html/

echo "========================================================================"
echo "¡Instalación completada exitosamente!"
echo "Puedes acceder al instalador de WordPress desde tu navegador en Windows."
echo "Busca la dirección IP de esta VM ejecutando el comando: ip a"
echo "========================================================================"
