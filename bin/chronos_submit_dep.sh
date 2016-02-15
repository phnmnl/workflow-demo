#!/bin/bash

curl -k -i -L -H 'Content-Type: application/json' -X POST -d@"$@" "https://$CHRONOS/scheduler/dependency"
echo #prints a newline

