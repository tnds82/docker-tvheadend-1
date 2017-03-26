#!/bin/bash

set -e

# Add tvheadend as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- /usr/bin/tvheadend "$@"
fi

# Fix permissions
if [ "$(stat -c %u:%g /tvh-data)" != "10710:10710" ]; then
    echo "--- /tvh-data does not belong to tvheadend, fix permissions";
    chown -R tvheadend:tvheadend /tvh-data;
fi

if [ ! -d /tvh-data/conf/accesscontrol ]; then
    echo "--- No user account set up, bootstrapping by starting with -C flag"
    set -- "$@" "-C"
fi

echo "--- Starting TVHeadend"
echo "--> $@"
exec "$@"
