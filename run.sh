#!/bin/sh
# 
# This script sets up the proxy users in the config and then runs
# apache, since it seems like it is
# hard to tell apached to treat an env var as an array.
#

sed -i "s/PROXY_USERS/{$PROXY_USERS}/g" /etc/apache2/conf.d/proxy.conf

exec httpd -DFOREGROUND
