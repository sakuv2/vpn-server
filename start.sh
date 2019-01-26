#!/bin/sh

cat << EOF > commands.txt
HubDelete DEFAULT
UserCreate ${USER_NAME} /GROUP:none /REALNAME:none /NOTE:none
UserPasswordSet ${USER_NAME} /PASSWORD:${USER_PASSWD}
IPsecEnable /L2TP:yes /L2TPRAW:no /ETHERIP:no /PSK:${VPN_PSK} /DEFAULTHUB:${HUB_NAME}
EOF

/usr/vpnserver/vpnserver start
sleep 5
vpncmd /SERVER localhost /ADMINHUB:DEFAULT /CMD HubCreate ${HUB_NAME} /PASSWORD:${HUB_PASSWD}
vpncmd /SERVER localhost /ADMINHUB:${HUB_NAME} /IN:commands.txt
/usr/vpnserver/vpnserver stop
sleep 5

brctl addbr brg0
brctl addif brg0 ${NIC}
ip a flush dev ${NIC}
ip a flush dev tan_vpn0
ip a add ${IP_ADDRESS} dev brg0
ip r add default via ${DEFAULT_GATEWAY}

echo "start vpnserver"
/usr/vpnserver/vpnserver execsvc
