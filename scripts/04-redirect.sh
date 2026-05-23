#!/bin/bash

# ==============================================================================
# Script de automatización para enrutamiento de dominio y redirección al POS
# ==============================================================================

echo "======================================================="
echo "1. Configurando redirección dinámica HTTP a HTTPS..."
echo "======================================================="
# Esto reemplaza el archivo anterior con una regla que respeta el dominio (ej. trapitos.local)
cat <<EOF > /etc/httpd/conf.d/redirect_http.conf
<VirtualHost _default_:443>
    RewriteEngine On
    RewriteRule ^(.*)$ https://%{HTTP_HOST}\$1 [R=301,L]
</VirtualHost>
EOF

echo "======================================================="
echo "2. Configurando redirección de la raíz (/) hacia /pos/..."
echo "======================================================="
HTACCESS_FILE="/var/www/html/.htaccess"
REDIRECT_RULE="RedirectMatch 301 ^/$ /pos/"

# Asegurar que el archivo .htaccess existe
touch $HTACCESS_FILE

# Comprobar si la regla ya existe para evitar duplicados si el script se corre varias veces
if grep -q "$REDIRECT_RULE" "$HTACCESS_FILE"; then
    echo "La regla de redirección ya existe en .htaccess. Omitiendo..."
else
    # Insertar la regla en la primera línea del archivo
    sed -i "1i $REDIRECT_RULE" "$HTACCESS_FILE"
    echo "Regla de redirección añadida al inicio de .htaccess"
fi

echo "======================================================="
echo "3. Reiniciando Apache (httpd)..."
echo "======================================================="
systemctl restart httpd

echo "======================================================="
echo "¡Configuración de enrutamiento completada!"
echo "Al entrar a http://trapitos.local serás llevado a https://trapitos.local/pos/"
echo "======================================================="
