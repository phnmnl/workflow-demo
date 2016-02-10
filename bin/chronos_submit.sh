#!/bin/bash

curl -k -i -L -H 'Content-Type: application/json' -X POST -d@"$@" "https://$CHRONOS/scheduler/iso8601"
echo #prints a newline

