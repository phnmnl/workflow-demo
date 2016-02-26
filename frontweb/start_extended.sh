#!/bin/bash
#

# first get environment variables into file
# (workaround because php in nginx image doesn't see environment vars)
/getenvs.sh

# run the startup script from nginx docker image
/start.sh
