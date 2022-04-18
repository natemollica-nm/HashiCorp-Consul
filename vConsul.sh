#!/bin/bash

Cluster=('bootstrap' 'consul-01' 'consul-02' 'consul-03' 'client-01' 'client-02')
ClusterRev=('client-02' 'client-01' 'consul-03' 'consul-02' 'consul-01' 'bootstrap')
ConsulServers=('consul-01' 'consul-02' 'consul-03')
ConsulClients=('client-01' 'client-02')

function consulAgentKill {
  echo "Terminating Consul Agent - $1"
  vagrant ssh $1 -c 'sudo service consul stop'
}

function startAgent {
  echo "Starting Consul Agent - $1"
  vagrant ssh $1 -c 'sudo service consul start'
}

function vagrantDestroy {
  vagrant destroy $1 -f &
  BACK_PID=$!
  while kill -0 $BACK_PID ; do
    echo "Destroying $1. Please wait."
    sleep 3
  done
}

function vagrantHalt {
  echo "Stopping $1"
  vagrant halt $1
}

function vagrantUp {
    vagrant up $1 &
    sleep 5
    echo "$1 Provisioning started..."
}

if [[ $1 == "-init" ]];then
  echo "Re-Initializing Consul Cluster!"

  # BEGIN: Consul Cluster Init
  echo "Provisioning Consul Cluster..."
  for i in "${Cluster[@]}"; do
    vagrantUp $i
  done
  echo "Consul Cluster Initialized!"

elif [[ $1 == "-stop" ]];then
  $Cluster = $ClusterRev
  for i in "${Cluster[@]}"; do 
    consulAgentKill $i
  done
  for i in "${Cluster[@]}"; do
    vagrantHalt $i
  done
  echo "Cluster Shutdown Complete!"

elif [[ $1 == "-destroy" ]];then
  $Cluster = $ClusterRev
  for i in "${Cluster[@]}"; do
    consulAgentKill $i
    vagrantDestroy $i
  done

else
  echo "Invalid script argument passed! Enter: '-init', '-start', '-stop', '-destroy' or '-reprovision'"
fi