#!/usr/bin/env bash

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

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "[OFFLINE-INSTALL] Configuring dependencies"
echo "This script will not work if you don't have the following dependencies installed"

echo "[OFFLINE-INSTALL] Configuring nginx"
if [ $(confirm "Do you want to configure nginx?") -eq "1" ]; then
  # Check if nginx is installed
  echo "[OFFLINE-INSTALL] Checking nginx installed"
  if [ $(rpm -qa | grep -c nginx) -eq 0 ]; then
    echo "[OFFLINE-INSTALL] Nginx is not installed"
    echo "[OFFLINE-INSTALL] Please install nginx first"
    echo "[OFFLINE-INSTALL] Aborting nginx configuration"
  else
    echo "[OFFLINE-INSTALL] Nginx is installed"
    echo "[OFFLINE-INSTALL] Checking nginx status"
    # Check if nginx is running
    if [ $(systemctl is-active nginx) == "active" ]; then
      echo "[OFFLINE-INSTALL] Nginx is running"
      echo "[OFFLINE-INSTALL] Stopping nginx"
      systemctl stop nginx
    else
      echo "[OFFLINE-INSTALL] Nginx is not running"
    fi
    sh script/config_nginx.sh
    echo "[OFFLINE-INSTALL] Enabling and starting nginx"
    systemctl enable nginx
    systemctl restart nginx
  fi
else
  echo "[OFFLINE-INSTALL] Skipping nginx configuration"
fi

echo "[OFFLINE-INSTALL] Configuring Redis"
if [ $(confirm "Do you want to configure Redis?") -eq "1" ]; then
  echo "[OFFLINE-INSTALL] Checking Redis installed"
  # Check if redis is installed
  if [ $(rpm -qa | grep -c redis) -eq 0 ]; then
    echo "[OFFLINE-INSTALL] Redis is not installed"
    echo "[OFFLINE-INSTALL] Please install Redis first"
    echo "[OFFLINE-INSTALL] Aborting Redis configuration"
  else
    echo "[OFFLINE-INSTALL] Redis is installed"
    echo "[OFFLINE-INSTALL] Checking Redis status"
    # Check if redis is running
    if [ $(systemctl is-active redis) == "active" ]; then
      echo "[OFFLINE-INSTALL] Redis is running"
      echo "[OFFLINE-INSTALL] Stopping Redis"
      systemctl stop redis
    else
      echo "[OFFLINE-INSTALL] Redis is not running"
    fi
    sh script/config_redis.sh
    echo "[OFFLINE-INSTALL] Enabling and starting Redis"
    systemctl enable redis
    systemctl restart redis
  fi
else
  echo "[OFFLINE-INSTALL] Skipping Redis configuration"
fi

echo "[OFFLINE-INSTALL] Configuring HAProxy"
if [ $(confirm "Do you want to configure HAProxy?") -eq "1" ]; then
  echo "[OFFLINE-INSTALL] Checking HAProxy installed"
  # Check if haproxy is installed
  if [ $(rpm -qa | grep -c haproxy) -eq 0 ]; then
    echo "[OFFLINE-INSTALL] HAProxy is not installed"
    echo "[OFFLINE-INSTALL] Please install HAProxy first"
    echo "[OFFLINE-INSTALL] Aborting HAProxy configuration"
  else
    echo "[OFFLINE-INSTALL] HAProxy is installed"
    echo "[OFFLINE-INSTALL] Checking HAProxy status"
    # Check if haproxy is running
    if [ $(systemctl is-active haproxy) == "active" ]; then
      echo "[OFFLINE-INSTALL] HAProxy is running"
      echo "[OFFLINE-INSTALL] Stopping HAProxy"
      systemctl stop haproxy
    else
      echo "[OFFLINE-INSTALL] HAProxy is not running"
    fi
    sh script/config_haproxy.sh
    systemctl enable haproxy
    systemctl restart haproxy
  fi
else
  echo "[OFFLINE-INSTALL] Skipping HAProxy configuration"
fi

echo "[OFFLINE-INSTALL] Configuring RabbitMQ"
if [ $(confirm "Do you want to configure RabbitMQ?") -eq "1" ]; then
  echo "[OFFLINE-INSTALL] Checking RabbitMQ installed"
  # Check if rabbitmq is installed
  if [ $(rpm -qa | grep -c rabbitmq) -eq 0 ]; then
    echo "[OFFLINE-INSTALL] RabbitMQ is not installed"
    echo "[OFFLINE-INSTALL] Please install RabbitMQ first"
    echo "[OFFLINE-INSTALL] Aborting RabbitMQ configuration"
  else
    echo "[OFFLINE-INSTALL] RabbitMQ is installed"
    echo "[OFFLINE-INSTALL] Checking RabbitMQ status"
    # Check if rabbitmq is running
    if [ $(systemctl is-active rabbitmq-server) == "active" ]; then
      echo "[OFFLINE-INSTALL] RabbitMQ is running"
    else
      echo "[OFFLINE-INSTALL] RabbitMQ is not running"
      echo "[OFFLINE-INSTALL] Starting RabbitMQ to initialize configuration"
      systemctl start rabbitmq-server
    fi
    sh script/config_rabbitmq.sh
    echo "[OFFLINE-INSTALL] Enabling and starting RabbitMQ"
    systemctl enable rabbitmq-server
    systemctl restart rabbitmq-server
  fi
else
  echo "[OFFLINE-INSTALL] Skipping RabbitMQ configuration"
fi

echo "[OFFLINE-INSTALL] Configuring MySQL"
if [ $(confirm "Do you want to configure MySQL?") -eq "1" ]; then
  echo "[OFFLINE-INSTALL] Checking MySQL installed"
  # Check if mysql is installed
  if [ $(rpm -qa | grep -c mysql) -eq 0 ]; then
    echo "[OFFLINE-INSTALL] MySQL is not installed"
    echo "[OFFLINE-INSTALL] Please install MySQL first"
    echo "[OFFLINE-INSTALL] Aborting MySQL configuration"
  else
    echo "[OFFLINE-INSTALL] MySQL is installed"
    echo "[OFFLINE-INSTALL] Checking MySQL status"
    # Check if mysql is running
    if [ $(systemctl is-active mysql) == "active" ]; then
      echo "[OFFLINE-INSTALL] MySQL is running"
      echo "[OFFLINE-INSTALL] Stopping MySQL"
      systemctl stop mysqld
    else
      echo "[OFFLINE-INSTALL] MySQL is not running"
    fi
    sh script/config_mysql.sh
    echo "[OFFLINE-INSTALL] Enabling and starting MySQL"
    systemctl enable mysqld
    systemctl restart mysqld
  fi
else
  echo "[OFFLINE-INSTALL] Skipping MySQL configuration"
fi

echo "[OFFLINE-INSTALL] Configuring sample"
echo "[OFFLINE-INSTALL] Done"