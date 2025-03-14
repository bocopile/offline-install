#!/usr/bin/env bash

confirm() {
  local yn
  while true; do
    read -p "$1 [y/N] : " yn
    yn=${yn:-n}
    case "$yn" in
      [Yy]* ) echo "1"; return;;
      [Nn]* ) echo "0"; return;;
    esac
  done
}

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ $(confirm "[OFFLINE-INSTALL] Installation Repository") -eq "1" ]; then
  echo "[OFFLINE-INSTALL] Setup Repository"
  read -p "Enter the full path of the repo folder: " REPO_FOLDER
  echo "[OFFLINE-INSTALL] Check the repo folder..."
  if [ ! -d "$REPO_FOLDER" ]; then
    mkdir -p $REPO_FOLDER
  fi

  echo "[OFFLINE-INSTALL] Extracting packages"
  rpm -i tar-1.30-9.el8.x86_64.rpm
  read -p "Enter the full path of the tar file (gz): " TAR_FILE
  if [ -f "$TAR_FILE" ]; then
    tar -zxvf $TAR_FILE -C $REPO_FOLDER
  else
    echo "$TAR_FILE is not exist"
    exit 1
  fi

  sudo rm -rf /etc/yum.repos.d/offine-install.repo

  echo "[OFFLINE-INSTALL] Creating repo"
  echo -e "[offine-install]\nname=RHEL8-OFFLINE-INSTALL-Repository\nbaseurl=file://$REPO_FOLDER/repo\nenabled=1\ngpgcheck=0\nmodule_hotfixes=1" | tee /etc/yum.repos.d/offine-install.repo > /dev/null
else
  echo "[OFFLINE-INSTALL] Skipping Repository Setup"
fi


if [ $(confirm "[OFFLINE-INSTALL] Installation Packages") -eq "0" ]; then
  echo "[OFFLINE-INSTALL] Skipping Installation"
  exit 0
fi

echo "[OFFLINE-INSTALL] Installing Common Dependencies"
yum --disablerepo=\* --enablerepo=offine-install install git

echo "[OFFLINE-INSTALL] Installing nginx"
if [ $(confirm "Do you want to install nginx?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install nginx -y
  # systemctl enable nginx
  # systemctl start nginx
fi

echo "[OFFLINE-INSTALL] Installing haproxy"
if [ $(confirm "Do you want to install haproxy?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install haproxy -y
  # systemctl enable haproxy
  # systemctl start haproxy
fi

echo "[OFFLINE-INSTALL] Installing proxysql"
if [ $(confirm "Do you want to install proxysql?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install proxysql -y
  # systemctl enable proxysql
  # systemctl start proxysql
fi

echo "[OFFLINE-INSTALL] Installing redis"
if [ $(confirm "Do you want to install redis?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install redis -y
  # systemctl enable redis
  # systemctl start redis
fi

echo "[OFFLINE-INSTALL] Installing rabbitmq"
if [ $(confirm "Do you want to install rabbitmq?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install socat logrotate -y
  yum --disablerepo=\* --enablerepo=offine-install install erlang rabbitmq-server -y
  # systemctl enable rabbitmq-server
  # systemctl start rabbitmq-server
fi

echo "[OFFLINE-INSTALL] Installing JDK 11 (latest)"
if [ $(confirm "Do you want to install JDK 11 (latest)?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install java-11-openjdk-devel -y
fi

echo "[OFFLINE-INSTALL] Installing docker-ce"
if [ $(confirm "Do you want to install docker-ce?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install --nobest install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  # systemctl enable docker
  # systemctl start docker
fi

echo "[OFFLINE-INSTALL] Installing mysql-5.7.44"
if [ $(confirm "Do you want to install mysql-5.7.44?") -eq "1" ]; then
  yum --disablerepo=\* --enablerepo=offine-install install mysql-community-server mysql-community-client -y
  # systemctl enable mysqld
  # systemctl start mysqld
fi

# echo "[OFFLINE-INSTALL] Installing NVM with Node12 & Node18"
# if [ $(confirm "Do you want to install NVM with Node12 & Node18?") -eq "1" ]; then
#   NVM_PACKAGE_FILE=nvm-packed-12-18.tar.xz
#   BASHRC=$HOME/.bashrc
#   NVM_EXPORT='export NVM_DIR="$HOME/.nvm"
#   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion'
#   if [ ! -d "$HOME/.nvm" ]; then
#     if [ -f "$NVM_PACKAGE_FILE" ]; then
#       echo "Installing nvm from $NVM_PACKAGE_FILE"
#       tar -xJvf "$NVM_PACKAGE_FILE" -C $HOME
#       sh $HOME/.nvm/install.sh
#     else
#       echo "$NVM_PACKAGE_FILE is not exist in $HOME"
#       exit 1
#     fi
#   else
#     echo "[OFFLINE-INSTALL] NVM already installed"
#   fi
#   TEMP_FILE=$(mktemp)
#   echo "$NVM_EXPORT" > "$TEMP_FILE"
  
#   if ! grep -F "$(cat "$TEMP_FILE")" "$BASHRC" > /dev/null; then
#     cat "$TEMP_FILE" >> "$BASHRC"
#   fi

#   rm -f "$TEMP_FILE"
#   echo "All setup"
#   echo "Reload bash profile 'source ~/.bashrc'"
# fi

echo "[OFFLINE-INSTALL] Installation Done"
echo "Please restart your terminal to apply changes"
