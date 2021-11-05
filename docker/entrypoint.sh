#!/bin/bash
# openfortivpn $host:$port -u $user -p $password --trusted-cert $cert
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

tmux new-session -s vpn -d "/usr/bin/expect -f ${vpnScript}||bash"


#TODO: replace your real service
python3 -m http.server 80
