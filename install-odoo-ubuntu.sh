#!/bin/bash

#######################################
# Bash script to install an odoo11 in Ubuntu
# Author: Subhash (serverkaka.com)

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check port 8069 is Free or Not
netstat -ln | grep ":8069 " 2>&1 > /dev/null
if [ $? -eq 1 ]; then
     echo go ahead
else
     echo Port 8069 is allready used
     exit 1
fi

# Update System
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Install Git, Pip, Node.js and the tools required to build Odoo dependencies
sudo apt install git python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less -y

# Create Odoo user
sudo useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

# Install and configure PostgreSQL
sudo apt-get install postgresql -y
sudo su - postgres -c "createuser -s odoo"

#Install Wkhtmltopdf
wget https://builds.wkhtmltopdf.org/0.12.1.3/wkhtmltox_0.12.1.3-1~bionic_amd64.deb
dpkg -i wkhtmltox_0.12.1.3-1~bionic_amd64.deb
apt-get -f install -y
dpkg -i wkhtmltox_0.12.1.3-1~bionic_amd64.deb

## Install and Configure Odoo
# First clone the odoo from the GitHub repository
su - odoo -c "git clone https://www.github.com/odoo/odoo --depth 1 --branch 11.0 /opt/odoo/odoo11"

# create a new virtual environment for our Odoo 11 installation run
#su - odoo -c "cd /opt/odoo"
su - odoo -c "cd /opt/odoo && python3 -m venv odoo11-venv"

# activate the environment and install all required Python modules with pip3
su - odoo -c "cd /opt/odoo && source odoo11-venv/bin/activate && pip3 install wheel && pip3 install -r odoo11/requirements.txt && deactivate"

#create a new directory for our custom modules run
sudo mkdir /opt/odoo/odoo11-custom-addons
sudo chown odoo: /opt/odoo/odoo11-custom-addons

# create a configuration file
cd /etc/
wget https://s3.amazonaws.com/serverkaka-pubic-file/odoo11/odoo11.conf

# Create a systemd unit service file
cd /etc/systemd/system/
wget https://s3.amazonaws.com/serverkaka-pubic-file/odoo11/odoo11.service

# Adjust the Firewall
ufw allow 8069/tcp

# start odoo11
sudo systemctl daemon-reload
sudo systemctl start odoo11
sudo systemctl status odoo11

# Set autostartup odoo
sudo systemctl enable odoo11

echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: 8069"
echo "Code location: /opt/odoo"
echo "Start Odoo service: sudo systemctl start odoo11"
echo "Stop Odoo service: sudo systemctl stop odoo11"
echo "Restart Odoo service: ssudo systemctl restart odoo11"
echo "-----------------------------------------------------------"
