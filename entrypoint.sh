#!/bin/bash

set -e

# Add tvheadend as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- /usr/bin/tvheadend "$@"
fi

# Fix permissions
if [ "$(stat -c %u:%g /config)" != "10710:10710" ]; then
    echo "--- /config does not belong to tvheadend, fix permissions";
    chown -R tvheadend:tvheadend /config;
fi

if [ ! -d /config/conf/accesscontrol ]; then
    echo "--- No user account set up, bootstrapping by starting with -C flag"
    set -- "$@" "-C"
fi

echo "--- Starting TVHeadend"
echo "--> $@"
exec "$@"
