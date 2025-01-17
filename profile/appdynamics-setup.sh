#!/bin/sh

logfile="/tmp/appdynamics-setup-profile.out.log"

if [ -n "${APPD_AGENT}" ]; then
  echo "Exiting. APPD_AGENT variable not set" >> "${logfile}"
  exit 0
fi

service="$(echo "${VCAP_SERVICES}" | jq -r '[.[][] | select(.name | match("app(-)?dynamics"))]')"
credentials=$(echo "${service}" | jq -r '.[0].credentials')

if [ -z "${credentials}" ]; then
  echo "Exiting. credentials not found in VCAP_SERVICES" >> "${logfile}"
  exit 0
fi

controller_host=$(echo "${credentials}" | jq -r '.["host-name"]')
controller_port=$(echo "${credentials}" | jq -r '.port')
account_name=$(echo "${credentials}" | jq -r '.["account-name"]')
ssl_enabled=$(echo "${credentials}" | jq -r '.["ssl-enabled"]')
account_access_key=$(echo "${credentials}" | jq -r '.["account-access-key"]')

if [ -n "${controller_host}" ]; then
  export APPDYNAMICS_CONTROLLER_HOST_NAME="${controller_host}"
fi

if [ -n "${controller_port}" ]; then
  export APPDYNAMICS_CONTROLLER_PORT="${controller_port}"
fi

if [ -n "${account_name}" ]; then
  export APPDYNAMICS_AGENT_ACCOUNT_NAME="${account_name}"
fi

if [ -n "${ssl_enabled}" ]; then
  export APPDYNAMICS_CONTROLLER_SSL_ENABLED="${ssl_enabled}"
fi

if [ -n "${account_access_key}" ]; then
  export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="${account_access_key}"
fi

application_name=$(echo "${VCAP_APPLICATION}" | jq -r '.application_name')
if [ -z "${application_name}" ]; then
  exit 0
fi

if [ -z "${APPDYNAMICS_AGENT_APPLICATION_NAME}" ]; then
  export APPDYNAMICS_AGENT_APPLICATION_NAME="${application_name}"
fi
if [ -z "${APPDYNAMICS_AGENT_TIER_NAME}" ]; then
  export APPDYNAMICS_AGENT_TIER_NAME="${application_name}"
fi
if [ -z "${APPDYNAMICS_AGENT_NODE_NAME}" ]; then
  export APPDYNAMICS_AGENT_NODE_NAME="${application_name}:${CF_INSTANCE_INDEX}"
fi
