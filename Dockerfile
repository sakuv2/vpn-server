FROM amazonlinux:2017.03

RUN yum install -y gcc make ncurses-devel openssl-devel readline-devel wget iproute bridge-utils

ARG SOFTETHER_URL="https://jp.softether-download.com/files/softether/v4.22-9634-beta-2016.11.27-tree/Source_Code/softether-src-v4.22-9634-beta.tar.gz"

RUN cd / && \
	mkdir -p softether_vpn && \
	cd softether_vpn && \
	wget ${SOFTETHER_URL} && \
	tar zxvf *.tar.gz && \
	cd $(tar ztvf *.tar.gz| head -n1 | awk '{print $NF}') && \
	cp -f src/makefiles/linux_64bit.mak Makefile && \
	make && \
	make install && \
	make clean && \
	rm -rf /softether_vpn

COPY batch.txt /tmp/
RUN cd /tmp && \
	/usr/vpnserver/vpnserver start && \
	sleep 5 && \
	vpncmd /SERVER localhost /ADMINHUB:DEFAULT /IN:batch.txt && \
	/usr/vpnserver/vpnserver stop

ENV HUB_NAME="VPN" \
	HUB_PASSWD="HubPassword" \
	USER_NAME="User" \
	USER_PASSWD="UserPassword" \
	VPN_PSK="vpn" \
	NIC="eth0" \
	IP_ADDRES='192.168.0.1' \
	DEFAULT_GATEWAY='192.168.0.254'

COPY start.sh /tmp/

ENTRYPOINT ["/tmp/start.sh"]

EXPOSE 500/udp 4500/udp 5555
