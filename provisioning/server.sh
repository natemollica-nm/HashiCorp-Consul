#!/bin/bash
 
# Step 1 - Clean Apt Repository directories and update source list.
rm -rf /var/lib/apt/lists/*

# Step 2 - Get the necessary utilities and install them.
apt-get update && apt-get -y upgrade && apt-get clean
apt-get install -y unzip
JQExe="/vagrant/linux_locals/jq_executable/jq"
EPath="/vagrant/configs/key"

# Step 3 - Copy Ubuntu Consul service file to /etc/systemd/system
cp /vagrant/configs/consul.service /etc/systemd/system/consul.service
sudo chmod --reference=/etc/systemd/system/default.target.wants /etc/systemd/system/consul.service

# Step 4 - Get the Consul Zip file and extract it.  
if [ -f "/usr/local/bin/jq" ]; then
  echo "JQ Executable already present..."
else
  cp "$JQExe" "/usr/local/bin/jq"
fi

if [ -f "/usr/local/bin/consul" ]; then
  rm -rf "/usr/local/bin/consul"
fi

# Retrieve and unzip(install) Consul Service binary
cd /usr/local/bin
wget -q https://releases.hashicorp.com/consul/1.11.4/consul_1.11.4_linux_amd64.zip
unzip *.zip
rm *.zip

# Consul Server Envoy side-car proxy service binary install
curl -L https://func-e.io/install.sh | bash -s -- -b /usr/local/bin
func-e use 1.18.3
sudo cp ~/.func-e/versions/1.18.3/bin/envoy /usr/local/bin/
 
# Step 5 - Make the Consul directory.
if [ -d "/etc/consul.d" ]
then
  rm -rf /etc/consul.d && mkdir -p /etc/consul.d
else
  mkdir -p /etc/consul.d
fi

# Step 6 - Make Consule Data Directory
if [ -d "/var/consul" ]
then
  rm -rf /var/consul && mkdir /var/consul
else
  mkdir /var/consul
fi

# Step 7 - Generate Consul Genkey for Encrypted Comms
if [[ ($HOSTNAME -eq "bootstrap") && (! -f $EPath) ]]; then
  touch $EPath
  consul keygen > $EPath
fi

if [[ $HOSTNAME -eq "consul-0*" ]]; then
  sudo cp /vagrant/configs/services/*.json /etc/consul.d/
fi

Key=$( cat ${EPath} )

# Step 8 - Update local config.json file for server specific info.
ConsulIP=$( ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 )
cat $1 | jq ".bind_addr |= \"$ConsulIP\"" | jq ".client_addr |= \"$ConsulIP\"" | jq ".advertise_addr |= \"$ConsulIP\"" | jq ".encrypt |= \"$Key\"" > /etc/consul.d/config.json
