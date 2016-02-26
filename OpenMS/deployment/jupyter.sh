#!/bin/bash

curl -k -i -L -X POST -H "Content-type: application/json" -d@json/jupyter.json https://admin:admin@192.168.100.101/marathon/v2/apps

