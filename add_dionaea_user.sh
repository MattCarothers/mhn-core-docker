#!/bin/sh

docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py \
	dionaea b64c2e86d0eb546e5b2757508df50222 \
	dionaea.connections,dionaea.dcerpcrequests,dionaea.shellcodeprofiles,dionaea.capture ""
