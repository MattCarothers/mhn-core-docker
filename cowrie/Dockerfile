FROM ubuntu:16.04

# Authentication information for hpfeeds in the broker container.
# Example command to add the credentials to the broker:
#
# docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py \
#	cowrie 7919ea5eb8ab8cc475e64dd074723b0b cowrie.sessions ""
ENV HPF_HOST=broker
ENV HPF_PORT=10000
ENV HPF_IDENT=cowrie
ENV HPF_SECRET=7919ea5eb8ab8cc475e64dd074723b0b

# You may want to change the cowrie user id inside the container if
# you're going to mount an external log directory.  The internal uid
# needs write permissions to the external volume.
#
# E.g. to save cowrie logs to /var/log/cowrie on the host OS, run docker with ...
#
# 	-v /var/log/cowrie:/opt/cowrie/log
# 
# ... and make sure /var/log/cowrie is writable by the cowrie uid inside the container.
ENV COWRIE_UID=1000

# Install packages
RUN apt-get update && apt-get install -y git supervisor

# Create the cowrie user
RUN useradd -u ${COWRIE_UID} -s /bin/false cowrie 

# Download the MHN distro
WORKDIR /usr/src
RUN git clone https://github.com/threatstream/mhn

# Run the install script.  The script will generate a bunch of errors, but we don't care.
WORKDIR /usr/src/mhn/scripts
RUN sed -i -e 's/set -e/#set -e/' deploy_cowrie.sh ; \
	# Cowrie has deprecated start/stop.sh \
	sed -i -e 's/start.sh env/bin\/cowrie start/' deploy_cowrie.sh ; \
	sed -i -e 's/start.sh/bin\/cowrie/' deploy_cowrie.sh ; \
	sed -i -e 's/ env/ cowrie-env/' deploy_cowrie.sh ; \
	bash deploy_cowrie.sh foo bar ; \
	apt-get -y purge '.*-dev' 

# Disable the json log and enable telnet
RUN sed -i -e 's/logfile = log\/cowrie.json/#logfile = log\/cowrie.json/' \
		/opt/cowrie/cowrie.cfg ; \
	sed -i -e 's/^enabled = false/enabled = true/' \
		/opt/cowrie/cowrie.cfg ; \
	sed -i -e 's/^listen_endpoints = tcp:2222/listen_endpoints = tcp:22/' \
		/opt/cowrie/cowrie.cfg ; \
	sed -i -e 's/^listen_endpoints = tcp:2223/listen_endpoints = tcp:23/' \
		/opt/cowrie/cowrie.cfg ; \
	touch /etc/authbind/byport/23; \
	chown cowrie /etc/authbind/byport/23; \
	chmod 770 /etc/authbind/byport/23;

EXPOSE 22
EXPOSE 23

COPY run.sh /

WORKDIR /opt/cowrie
CMD ["/run.sh"]

# How to run the container:
#
# docker run --rm --name cowrie --link broker cowrie
#
# To log outside the container:
#
# mkdir /var/log/cowrie
# chown 1000 /var/log/cowrie
# docker run --rm --name cowrie -v /var/log/cowrie:/opt/cowrie/log --link broker cowrie
