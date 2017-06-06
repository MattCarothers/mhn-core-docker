#!/bin/sh

docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py cowrie 7919ea5eb8ab8cc475e64dd074723b0b cowrie.sessions ""
