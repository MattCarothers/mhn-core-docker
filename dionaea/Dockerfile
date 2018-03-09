FROM ubuntu:16.04

# Authentication information for hpfeeds in the broker container.
# Example command to add the credentials to the broker:
#
# docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py \
#	dionaea b64c2e86d0eb546e5b2757508df50222 dionaea.connections ""
# docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py \
#	dionaea b64c2e86d0eb546e5b2757508df50222 dionaea.dcerpcrequests ""
# docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py \
#	dionaea b64c2e86d0eb546e5b2757508df50222 dionaea.shellcodeprofiles ""
# docker exec broker /opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/add_user.py \
#	dionaea b64c2e86d0eb546e5b2757508df50222 dionaea.capture ""
ENV HPF_HOST=broker
ENV HPF_PORT=10000
ENV HPF_IDENT=dionaea
ENV HPF_SECRET=b64c2e86d0eb546e5b2757508df50222

# You may want to change the dionaea user id inside the container if
# you're going to mount an external log directory.  The internal uid
# needs write permissions to the external volume.
#
# E.g. to save dionaea logs to /var/log/dionaea on the host OS, run docker with ...
#
# 	-v /var/log/dionaea:/opt/dionaea/log
# 
# ... and make sure /var/log/dionaea is writable by the dionaea uid inside the container.
ENV DIONAEA_UID=1000

# Install packages
RUN apt-get update && apt-get install -y supervisor autoconf automake \
	build-essential git htop libcurl4-openssl-dev libemu-dev libgc-dev \
	libev-dev libglib2.0-dev libloudmouth1-dev libnetfilter-queue-dev \
	libpcap-dev libreadline-dev libsqlite3-dev libssl-dev libtool libudns-dev \
	pkg-config sqlite3 subversion python3 cython3 python3-pip

# Create the dionaea user
RUN useradd -u ${DIONAEA_UID} -s /bin/false dionaea 

# Download dionaea and compile it
RUN \
	cd /usr/src && \
	git clone https://github.com/ThomasAdam/liblcfg.git && \
	cd liblcfg/code && \
	autoreconf -vi && \
	./configure --prefix=/opt/dionaea && \
	make install && \
	cd /usr/src && \
	git clone https://github.com/threatstream/mhn && \
	git clone https://github.com/gento/dionaea.git dionaea && \
	cp mhn/server/mhn/static/hpfeeds.py dionaea/modules/python/scripts/ && \
	cd dionaea && \
	autoreconf -vi && \
	ln -s /usr/bin/python3 /usr/bin/python3.2 && \
	ln -s /usr/bin/cython3 /usr/bin/cython && \
	pip3 install -e git+https://github.com/HurricaneLabs/pyev.git#egg=pyev && \
	./configure --disable-werror --prefix=/opt/dionaea \
		--with-lcfg-include=/opt/dionaea/include/ \
		--with-lcfg-lib=/opt/dionaea/lib/ && \
	sed -i -e 's/-Werror//' modules/nfq/Makefile && \
	make LDFLAGS=-lcrypto && \
	make install && \
	# Format string update for Python 3.4+ \
	sed -i -e 's/{:s}/{!s:s}/g' /opt/dionaea/lib/dionaea/python/dionaea/sip/__init__.py && \
	sed -i -e 's/{:/{!s:/g' /opt/dionaea/lib/dionaea/python/dionaea/mssql/mssql.py && \
	chown $DIONAEA_UID /opt/dionaea/var/dionaea

COPY dionaea.conf /opt/dionaea/etc/dionaea/
COPY supervisor-dionaea.conf /etc/supervisor/conf.d/dionaea.conf

RUN \
	sed -i -e "s/HPF_HOST/$HPF_HOST/" /opt/dionaea/etc/dionaea/dionaea.conf && \
	sed -i -e "s/HPF_PORT/$HPF_PORT/" /opt/dionaea/etc/dionaea/dionaea.conf && \
	sed -i -e "s/HPF_IDENT/$HPF_IDENT/" /opt/dionaea/etc/dionaea/dionaea.conf && \
	sed -i -e "s/HPF_SECRET/$HPF_SECRET/" /opt/dionaea/etc/dionaea/dionaea.conf

EXPOSE 21
EXPOSE 42
EXPOSE 80
EXPOSE 135
EXPOSE 443
EXPOSE 445
EXPOSE 1433
EXPOSE 1723
EXPOSE 1883
EXPOSE 3306
EXPOSE 5060
EXPOSE 5061

EXPOSE 69/udp
EXPOSE 1900/udp
EXPOSE 5060/udp

WORKDIR /opt/dionaea
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

# How to run the container:
#
# docker run --rm --name dionaea --link broker dionaea
#
# To log outside the container:
#
# mkdir /var/log/dionaea
# chown 1000 /var/log/dionaea
# docker run --rm --name dionaea -v /var/log/dionaea:/opt/dionaea/log --link broker dionaea
