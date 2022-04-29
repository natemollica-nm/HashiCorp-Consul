#!/bin/bash
set -e
Cluster=('consul-server-1' 'consul-server-2' 'consul-server-3' 'consul-server-4' 'consul-server-5' 'consul-server-6')
ClusterRev=('consul-client-1' 'consul-server-6' 'consul-server-5' 'consul-server-4' 'consul-server-3' 'consul-server-2' 'consul-server-1')
ConsulServers=('consul-server-1' 'consul-server-2' 'consul-server-3' 'consul-server-4' 'consul-server-5' 'consul-server-6')
ConsulClients=('consul-client-1')

function consulAgentKill {
  vagrant ssh "$1" -c 'sudo service consul stop'
}

function startAgent {
  vagrant ssh "$1" -c 'sudo service consul start'
}

function vagrantDestroy {
  vagrant destroy "$1" -f &
  BACK_PID=$!
  while kill -0 $BACK_PID ; do
    sleep 3
  done
}

function vagrantHalt {
  vagrant halt "$1"
}

function vagrantUp {
  vagrant up "$1" &
  sleep 5
  echo "$1 Provisioning started..."
}

case $1 in
  "-init")
    for i in "${Cluster[@]}"; do vagrantUp "$i"; done;;
  "-stop")
    for i in "${ClusterRev[@]}"; do consulAgentKill "$i"; done;;
  "-destroy")
    for i in "${ClusterRev[@]}"; do consulAgentKill "$i"; vagrantDestroy "$i"; done;;
esac