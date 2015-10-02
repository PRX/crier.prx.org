#!/bin/sh
set -e

echo "worker start"

cd $APP_HOME
exec /sbin/setuser app bundle exec shoryuken -R -C $APP_HOME/config/shoryuken.yml 2>&1

echo "worker running"
