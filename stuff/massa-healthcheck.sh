#!/usr/bin/bash


PROCESS_NAME="massa-node"
PROCESS_PORT=33035


if [[ -z "$(pgrep $PROCESS_NAME)" ]]; then
   echo "$PROCESS_NAME not running. Exiting..."
   exit 1
fi

if [[ -z "$(lsof -t -i:$PROCESS_PORT)" ]]; then
   echo "$PROCESS_NAME not listening on port $PROCESS_PORT. Exiting..."
   exit 1   
fi

echo "Healthcheck passed"
exit 0
