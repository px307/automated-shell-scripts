#!/bin/bash

E_WRONG_ARG=65
E_EXISTED=66

if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` server_port"
	exit $E_WRONG_ARG
fi

server_port=$1
read -p "Please input the server password: " password

if [ -e /usr/bin/ssserver ]
then
	echo "/usr/bin/ssserver exists, now exit."
	exit $E_EXISTED
fi


yum install epel-release -y
yum install python-pip -y

pip install shadowsocks

# Config shadowsocks config file
cat > /etc/shadowsocks.json << EOF
{
    "server":"0.0.0.0",
    "server_port":$server_port,
    "local_address": "127.0.0.1",
    "local_port":1081,
    "password":"$password",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false,
    "workers": 1
}
EOF

/usr/bin/ssserver -c /etc/shadowsocks.json -d start

echo

netstat -lntp | grep $server_port

# Config ssserver at startup
server=shadowsocks
if grep -q $server /etc/rc.local
then
        echo "$server have configured in /etc/rc.local"
else
        echo "# Start ssserver" >> /etc/rc.local
        echo "/usr/bin/ssserver -c /etc/shadowsocks.json -d start" >> /etc/rc.local
        grep $server /etc/rc.local
fi
