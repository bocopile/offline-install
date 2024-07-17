#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function ssl_check {
  # Setup ssl
  if [ $(confirm "Do you want to add SSL configuration?") -eq "1" ]; then
    read -p "Enter the SSL certificate path: " SSL_CERT
    read -p "Enter the SSL certificate key path: " SSL_KEY
    echo "    ssl on;
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;
    ssl_session_timeout 5m;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_prefer_server_ciphers  on;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    if (\$scheme = "https") {
        set \$ssl_header SSL;
    }
" >> $1
    read -p "Enter the server domain: " SERVER_DOMAIN
    echo "server_name $SERVER_DOMAIN;" >> $1
  fi
}

function confirm {
  while true
  do
    read -p "$1 [y/n] : " yn
    case $yn in
      [Yy] ) echo "1"; break;;
      [Nn] ) echo "0"; break;;
    esac
  done
}

echo "[OFFLINE-INSTALL] Creating Nginx Config"
read -p "Enter the full path of the nginx config folder: " NGINX_CONF
# if null then default /etc/nginx/conf.d
NGINX_CONF=${NGINX_CONF:-/etc/nginx/conf.d}

# Step 0. Add upstream and server block for SampleAPI
if [ $(confirm "Do you want to add upstream and server block for sampleAPI?") -eq "1" ]; then
  read -p "Enter the origin port for SampleAPI (default 3580): " SAMPLE_PORT
  # if null then default 3580
  SAMPLE_PORT=${SAMPLE_PORT:-3580}
  rm -rf $NGINX_CONF/webapi.conf
  echo "upstream webapi {
    server localhost:$SAMPLE_PORT;
}" >> $NGINX_CONF/webapi.conf
fi


echo "[OFFLINE-INSTALL] Nginx Config is created"
echo "Please check the config files in $NGINX_CONF"
echo "You can check the nginx config by running 'nginx -t'"
echo "[OFFLINE-INSTALL] Nginx configuration is done"
echo "[OFFLINE-INSTALL] Ngnix restart"
systemctl enable nginx
systemctl restart nginx