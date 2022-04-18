#!/bin/bash
echo "Enabling Consul as service..."
sudo systemctl enable consul.service
echo "Reloading systemctl daemon..."
sudo systemctl daemon-reload &
sleep 2
echo "+++ Starting Consul Service +++"
sudo service consul start
echo "+++ Verifying Consul Service Running +++"
pgrep -x consul
if [[ $? == 0 ]];then
  echo "+++ Consul Service Started +++"
else
  echo "--- Consul Service FAILED to Start ---"
fi