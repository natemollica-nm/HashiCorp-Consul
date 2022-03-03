#!/bin/bash

Cluster=('bootstrap' 'consul-01' 'consul-02' 'consul-03' 'client-01' 'client-02')
ClusterRev=('client-02' 'client-01' 'consul-03' 'consul-02' 'consul-01' 'bootstrap')
ConsulServers=('consul-01' 'consul-02' 'consul-03')
ConsulClients=('client-01' 'client-02')

function consulAgentKill {
  echo "Terminating Consul Agent - $1"
  vagrant ssh $1 -c 'consul_pid=$( pidof consul ) && sudo kill -INT $consul_pid'
}

function vagrantDestroy {
  vagrant destroy $1 -f &
  BACK_PID=$!
  while kill -0 $BACK_PID ; do
    echo "Destroying $1. Please wait."
    sleep 3
  done
}

function vagrantUp {
  vagrant up $1 &
  # Give the provisioning process time to lead/finish.
  sleep 5
  echo "$1 Startup started!"
}

function vagrantHalt {
  echo "Stopping $1"
  vagrant halt $1
}

function vagrantProvision {
  vagrant up $1  --provision &
  # Give the provisioning process time to lead/finish.
  sleep 5
  echo "$1 Re-provisioning started!"
}

if [[ $1 == "-init" ]];then
  echo "Re-Initializing Consul Cluster!"

  # BEGIN: Agent Kill
  for i in "${ClusterRev[@]}"; do 
    consulAgentKill $i
  done

  # BEGIN: Destroy and Rebuild
  echo "Destroying and Re-Provisioning Consul Cluster..."
  for i in "${Cluster[@]}"; do
    vagrantDestroy $i
    vagrantUp $i
  done
  echo "Consul Cluster Re-Initialized!"

elif [[ $1 == "-start" ]];then
  for i in "${Cluster[@]}"; do
    vagrantUp $i
  done
  echo "Consul Cluster startup complete!"

elif [[ $1 == "-stop" ]];then
  for i in "${ClusterRev[@]}"; do 
    consulAgentKill $i
  done
  for i in "${ClusterRev[@]}"; do
    vagrantHalt $i
  done
  echo "Cluster Shutdown Complete!"

elif [[ $1 == "-reprovision" ]];then
  for i in "${Cluster[@]}"; do
    vagrantProvision $i
  done
  echo "Cluster Re-provisioning complete!"

elif [[ $1 == "-destroy" ]];then
  for i in "${ClusterRev[@]}"; do
    vagrantDestroy $i
  done

else
  echo "Invalid script argument passed! Enter: '-init', '-start', '-stop', '-destroy' or '-reprovision'"
fi