#!/bin/bash

if [ $EUID -ne 0 ];then
    echo "need run as root"
    exit 1
fi

function install(){
    cmd=${1:?'install: missing cmd name'}

    if ! command -v ${cmd} >/dev/null 2>&1;then
        apt-get update
        apt-get install ${cmd} -y || { echo "install ${cmd} failed!"; exit 3; }
    fi
}


install openfortivpn
install expect
install tmux


source credential || { echo "load credential failed!"; exit 2; }
twoFa=$(cat 2fa | tr -d '\n')
echo "2fa code: $twoFa"

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

