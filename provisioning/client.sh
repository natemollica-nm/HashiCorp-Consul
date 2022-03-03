#!/bin/bash
 
# Step 1 - Clean Apt Repository directories and update source list.
rm -rf /var/lib/apt/lists/*
# rm -f /etc/apt/sources.list
# cp /vagrant/linux_locals/sources.list /etc/apt/

# Step 2 - Get the necessary utilities and install them.
apt-get update && apt-get -y upgrade && apt-get clean
apt-get install -y unzip
JQExe="/vagrant/linux_locals/jq_executable/jq"
EPath="/vagrant/configs/key"
 
# Step 3 - Copy the upstart script to the /etc/init folder.
cp /vagrant/configs/consul.conf /etc/init/consul.conf
 
# Step 4 - Get the Consul Zip file and extract it.  
if [ -f "/usr/local/bin/jq" ]; then
  echo "JQ Executable already present..."
else
  cp "$JQExe" "/usr/local/bin/jq"
fi

if [ -f "/usr/local/bin/consul" ]; then
  rm -rf "/usr/local/bin/consul"
fi

cd /usr/local/bin
wget -q https://releases.hashicorp.com/consul/1.11.4/consul_1.11.4_linux_amd64.zip
unzip *.zip
rm *.zip
 
# Step 5 - Make the Consul directory.
if [ -d "/etc/consul.d" ]
then
  rm -rf /etc/consul.d && mkdir -p /etc/consul.d
else
  mkdir -p /etc/consul.d
fi

if [ -d "/var/consul" ]
then
  rm -rf /var/consul && mkdir /var/consul
else
  mkdir /var/consul
fi

Key=""

if [[ -f $EPath ]]; then
  Key=$( cat ${EPath} )
else
  echo "Consul DataCenter Key not found at ${EPath}. Ensure DC Bootstrap installation was successful..."
fi

# Step 6 - Copy the server configuration.
ConsulIP=$( ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1 )
cat $1 | jq ".bind_addr |= \"$ConsulIP\"" | jq ".client_addr |= \"$ConsulIP\"" | jq ".advertise_addr |= \"$ConsulIP\"" | jq ".encrypt |= \"$Key\"" > /etc/consul.d/config.json
