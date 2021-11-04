#!/bin/bash
source credential
twoFa=$(cat 2fa | tr -d '\n')
echo "2fa code: $twoFa"

if [ $EUID -ne 0 ];then
    echo "need run as root"
    exit 1
fi

if ! command -v openfortivpn >/dev/null 2>&1;then
    apt-get install openfortivpn -y || { echo "install openfortivpn failed!"; exit 2; }
fi

if ! command -v expect >/dev/null 2>&1;then
    apt-get install expect -y || { echo "install expect failed!"; exit 3; }
fi

vpnScript=/tmp/vpn.expect
configFile=config

cat<<EOF>${vpnScript}
#!/usr/bin/expect -f
spawn openfortivpn -c ${configFile}
expect {
    "*account password:" { send "$password\r"; exp_continue }
    "*authentication token:" { send "$twoFa\r" }
}
interact

EOF


sessionName=fortiClient
if tmux ls -F '#{session_name}' 2>/dev/null| grep -q ${sessionName};then
    echo "already running."
    return 0
fi

echo "create session: ${sessionName}"
tmux new-session -s ${sessionName} "sudo /usr/bin/expect -f ${vpnScript} || bash"

