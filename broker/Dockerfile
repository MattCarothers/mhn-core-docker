FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y git wget supervisor sudo lsb-core

WORKDIR /usr/src
RUN git clone https://github.com/MattCarothers/mhn

# Mongo needs to be running before we can install anything else.
# install_mongo also runs from install_hpfeeds, but it doesn't
# start the daemon, so we have to run it alone first.
COPY mongodb.conf /etc/supervisor/conf.d/
WORKDIR /usr/src/mhn/scripts
RUN ./install_mongo.sh ; \
	mkdir -p /var/log/mhn ; \
	/etc/init.d/supervisor start ; \
	./install_hpfeeds.sh ; \
	./install_honeymap.sh ; \
	./install_hpfeeds-logger-json.sh ; \
	apt-get -y purge '.*-dev' ; \
	rm -rf /usr/share/go

EXPOSE 3000
EXPOSE 10000

WORKDIR /
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
