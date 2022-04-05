#!/bin/bash
vpnScript=/tmp/vpn.expect
cat<<EOF>${vpnScript}
#!/usr/bin/expect -f
spawn openfortivpn $host:$port -u $user --trusted-cert=$cert 
expect {
	"*account password:" { send "$password\r"; exp_continue}
	"*authentication token:" { send "$twoFa\r" }
}
interact

EOF


if [[ ${hsmOn} == "yes" ]];then
    tmux new-session -s vpn -d "/usr/bin/expect -f ${vpnScript} || bash"

    while ! ip link show ppp0;do
        echo 'no ppp0'
        sleep 2
    done

	ip route del default dev ppp0
	ip route add 192.168.10.0/24 dev ppp0
	ip route add default via 172.17.0.1 dev eth0

fi

#TODO: replace your real service
python3 -m http.server 80
