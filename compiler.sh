#!/bin/bash

#   After entering coin name and github link automatically build coin

output() {
    printf "\E[0;33;40m"
    echo $1
    printf "\E[0m"
}
displayErr() {
    echo
    echo $1;
    echo
    exit 1;
}
output "Installing dependicies on your system!"
# Ensure that the system is up to date
sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get -y install curl nano vim git
sudo apt-get -y install unzip
sudo apt-get -y install systemd
# Swap
sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=1000
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
sudo chmod 0600 /var/swap.img
sudo chown root:root /var/swap.img
# Install dependencies there might be more based on your system
# However below instructions are for the fresh Ubuntu install/server
# Please carefully watch the logs because if something could not be install
# You have to make sure it is installed properly by trying the command or that particular
# dependency again
sudo apt-get -y install build-essential libtool autotools-dev autoconf pkg-config libssl-dev
sudo apt-get -y install libboost-all-dev
sudo apt-get -y install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
sudo apt-get -y install libqrencode-dev autoconf openssl libssl-dev libevent-dev
sudo apt-get -y install libminiupnpc-dev
#BerkeleyDB is required for the wallet.
sudo apt install software-properties-common
#sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu xenial universe"
sudo add-apt-repository ppa:bitcoin/bitcoin
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
output ""
    read -e -p "Enter the name of the coin : " coin
    read -e -p "Paste the github link for the coin : " git_hub
if [[ -d "$coin" ]]; then
    output "$coin already exists" 1>&2
else
    sudo  git clone $git_hub  $coin
fi
if [ ! -f "${coin}/src/${coin}d" ]; then
cd "${coin}"
if [ -f autogen.sh ]; then
sudo ./autogen.sh
sudo ./configure
sudo make
cd ..
fi
output "$coin build finished and can be found in $coin/src/ If coin daemon and coin-cli exists they will be copied to /usr/local/bin so they can be accessed globaly"
fi
if [ -f "/usr/local/bin/${coin}d" ]; then
    output "${coin}d already exists" 1>&2
else
echo "${coin}/src/${coin}d"
sudo chmod +x "${coin}/src/${coin}d"
sudo cp "${coin}/src/${coin}d" /usr/local/bin/
fi
if [ -f "/usr/local/bin/${coin}-cli" ]; then
    output "${coin}-cli already exists" 1>&2
else
sudo chmod +x "${coin}/src/${coin}-cli"
sudo cp "${coin}/src/${coin}-cli" /usr/local/bin/
fi
"${coin}d" -daemon -txindex
sleep 5
"${coin}-cli" getmininginfo
sleep 5
"${coin}-cli" stop
cd
output "Create coin.conf"
    read -e -p "Enter the rpcuser : " rpcuser
    read -e -p "Enter the rpcpassword : " rpcpassword
    read -e -p "Enter the rpcport : " rpcport
    read -e -p "Enter server IP address : " ip
    read -e -p "Enter the port : " port
echo '
rpcuser='$rpcuser'
rpcpassword='$rpcpassword'
rpcport='$rpcport'
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
txindex=1
logtimestamps=1
maxconnections=256
externalip='$ip'
bind='$ip':'$port'
' | sudo -E tee ".${coin}core/${coin}.conf" >/dev/null 2>&1
sudo chmod 0600 ".${coin}core/${coin}.conf"
echo "~/.${coin}core/${coin}.conf"
"${coin}d" -daemon -txindex
sleep 5
"${coin}-cli" getmininginfo
curl -u '$rpcuser':'$rpcpassword' --data-binary '{"id":"t0", "method": "getinfo", "params": [] }' http://127.0.0.1:'$rpcport'
output "Everything OK"
