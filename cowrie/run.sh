#!/bin/sh

# The tty directory needs to exist in order to log terminal sessions
if [ ! -d /opt/cowrie/log/tty ]; then
	mkdir -p /opt/cowrie/log/tty
	chown cowrie /opt/cowrie/log/tty
fi 

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
