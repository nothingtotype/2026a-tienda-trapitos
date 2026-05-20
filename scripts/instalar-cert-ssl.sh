#!/bin/bash

# ==============================================================================
# Script de automatización para habilitar mod_ssl en Rocky Linux (Apache/httpd)
# ==============================================================================

# Cargar variables de entorno desde el archivo config.env
if [ -f "config.env" ]; then
    source config.env
else
    echo "Error: El archivo config.env no existe. Por favor, copia config.env.example a config.env y añade tus datos."
    exit 1
fi

echo "======================================================="
echo "1. Actualizando los repositorios del sistema..."
echo "======================================================="
dnf update -y

echo "======================================================="
echo "2. Instalando el paquete mod_ssl..."
echo "======================================================="
dnf install mod_ssl -y

echo "======================================================="
echo "3. Configurando el firewall para permitir tráfico HTTPS..."
echo "======================================================="
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

echo "======================================================="
echo "4. Generando certificado SSL/TLS autofirmado..."
echo "======================================================="
openssl req -newkey rsa:2048 -nodes \
  -keyout /etc/pki/tls/private/httpd.key \
  -x509 -days 365 \
  -out /etc/pki/tls/certs/httpd.crt \
  -subj "/C=${SSL_COUNTRY}/ST=${SSL_STATE}/L=${SSL_LOCALITY}/O=${SSL_ORG}/CN=${SERVER_IP}"

echo "======================================================="
echo "5. Configurando Apache para usar los nuevos certificados..."
echo "======================================================="
sed -i 's|SSLCertificateFile /etc/pki/tls/certs/localhost.crt|SSLCertificateFile /etc/pki/tls/certs/httpd.crt|g' /etc/httpd/conf.d/ssl.conf
sed -i 's|SSLCertificateKeyFile /etc/pki/tls/private/localhost.key|SSLCertificateKeyFile /etc/pki/tls/private/httpd.key|g' /etc/httpd/conf.d/ssl.conf

echo "======================================================="
echo "6. Creando redirección de HTTP a HTTPS..."
echo "======================================================="
cat <<EOF > /etc/httpd/conf.d/redirect_http.conf
<VirtualHost _default_:80>
    ServerName $SERVER_IP
    Redirect permanent / https://$SERVER_IP/
</VirtualHost>
EOF

echo "======================================================="
echo "7. Reiniciando Apache (httpd) para aplicar los cambios..."
echo "======================================================="
systemctl restart httpd
systemctl enable httpd

echo "======================================================="
echo "¡Proceso completado con éxito!"
echo "Ahora puedes acceder a la interfaz en: https://$SERVER_IP/pos"
echo "======================================================="
