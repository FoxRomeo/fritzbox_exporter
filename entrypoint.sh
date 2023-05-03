#!/bin/sh

if [ -z "${USERNAME}" ]; then
  echo "ERROR: no USERNAME set"
  echo "will not work without a USERNAME"
  exit 1
fi

if [ -z "${PASSWORD}" ]; then
  echo "ERROR: no PASSWORD set"
  echo "will not work without a PASSWORD"
  exit 2
fi

PARAMETERS="-username ${USERNAME} -password ${PASSWORD}"

if [ -n "${LISTEN_PORT}" ]; then
  LISTEN_ADDRESS="-listen-address 0.0.0.0:${LISTEN_PORT}"
else
  LISTEN_ADDRESS="-listen-address 0.0.0.0:9042"
fi

if [ -n "${GATEWAY}" ]; then
  GATEWAY_URL="-gateway-url http://${GATEWAY}:49000"
  if [ -z "${NOLUA}"] ; then
    GATEWAY_LUA="-gateway-luaurl http://${GATEWAY}"  
  fi
fi

if [ -n "${METRICS}" ]; then
  METRICS="-metrics-file ${METRICS}"
fi

if [ -n "${LUA_METRICS}" ] && [ -z "${NOLUA}" ]; then
  LUA_METRICS="-lua-metrics-file ${LUA_METRICS}"
fi

if [ -n "${NOLUA}" ] && [ "${NOLUA}" -ne "0" ]; then
  NOLUA="-nolua ${NOLUA}"
fi

if [ -n "${VERIFYTLS}" ] && [ "${VERIFYTLS}" -ne "0" ]; then
  VERIFYTLS="-verifyTls ${VERIFYTLS}"
fi

if [ -n "${LOGLEVEL}" ]; then
  LOGLEVEL="-log-level ${LOGLEVEL}"
fi

PARAMETERS="${PARAMETERS} ${LISTEN_ADDRESS} ${GATEWAY_URL} ${GATEWAY_LUA} ${METRICS} ${LUA_METRICS} ${NOLUA} ${VERIFYTLS} ${LOGLEVEL}"

echo "#!/bin/sh" > /app/fritzbox_exporter.sh
echo >> /app/fritzbox_exporter.sh
echo "/app/fritzbox_exporter ${PARAMETERS}" >> /app/fritzbox_exporter.sh

