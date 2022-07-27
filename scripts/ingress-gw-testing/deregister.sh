#bin/bash
DATACENTER="${DATACENTER:=dc1}"
SERVICE_ID="$1"
NODE="${NODE:=$HOSTNAME}"

function retry {
  local -r cmd="$1"
  local -r description="$2"

  for i in $(seq 1 5); do
    log_info "Attempt #${i} -- $description"

    # The boolean operations with the exit status are there to temporarily circumvent the "set -e" at the
    # beginning of this script which exits the script immediately for error status while not losing the exit status code
    output=$(eval "$cmd") && exit_status=0 || exit_status=$?
    log_info "$output"
    if [[ $exit_status -eq 0 ]]; then
      echo "$output"
      return
    fi
    log_warn "$description failed. Will sleep for 10 seconds and try again."
    sleep 10
  done;

  log_error "$description failed after 5 attempts."
  exit $exit_status
}

deregister=""
deregister=$(cat <<-EOF
{
  "Datacenter": "${DATACENTER}",
  "Node": "${NODE}",
  "ServiceID": "${SERVICE_ID}"
}
EOF
)
echo -e "$deregister" |  sudo tee ./deregister.json


curl \
  --request PUT \
  --data @deregister.json "http://127.0.0.1:8500/v1/agent/service/deregister/$SERVICE_ID"

retry \
  "curl --request PUT --data @deregister.json http://127.0.0.1:8500/v1/agent/service/deregister/$SERVICE_ID" \
  "Deregistering Service ID: $SERVICE_ID"