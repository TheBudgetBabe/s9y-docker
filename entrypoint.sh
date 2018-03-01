#!/bin/bash
# vim: set ts=8 tw=0 noet :

set -e -o pipefail

decofile=${DECOFILE:-/var/run/secrets/deco.json}
/usr/local/bin/deco validate ${DECOFILE} && /usr/local/bin/deco run ${decofile}

if [ ! -z "${FRESHINSTALL}" ]; then
    echo "Starting with a fresh install"
    rm -f /var/www/html/serendipity/serendipity_config_local.inc.php
fi

# Change ownership to enable online updates
chown -R www-data /var/www/html/serendipity

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
	. "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_PID_FILE:=${APACHE_RUN_DIR:=/var/run/apache2}/apache2.pid}"
rm -f "$APACHE_PID_FILE"

# Hand over to apache as PID 1
exec apache2 -DFOREGROUND
