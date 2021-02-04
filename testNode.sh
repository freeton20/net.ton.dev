#!/bin/bash
apt-get update
yes | apt-get upgrade
yes | apt install git -y
cd /
git clone https://github.com/tonlabs/net.ton.dev.git
cd /net.ton.dev/scripts
./env.sh

#fix bug with path to config
export NETWORK_TYPE=net.ton.dev

./build.sh
./setup.sh
export PATH=$PATH:/net.ton.dev/tonos-cli
./msig_genaddr.sh
echo 'Send tons here:'
cat ~/ton-keys/$(hostname -s).addr
read

#deploy multisig contract

#download multisig contract files
wget https://raw.githubusercontent.com/tonlabs/ton-labs-contracts/b79bf98b89ae95b714fbcf55eb43ea22516c4788/solidity/safemultisig/SafeMultisigWallet.abi.json

wget https://github.com/tonlabs/ton-labs-contracts/raw/b79bf98b89ae95b714fbcf55eb43ea22516c4788/solidity/safemultisig/SafeMultisigWallet.tvc

#get public key (owner of the wallet)
OWNER=`echo $a | sed -n 's/.*public": "\(.*\)".*/\1/p' ~/ton-keys/msig.keys.json`
#deploy
tonos-cli deploy ./SafeMultisigWallet.tvc '{"owners":["0x'${OWNER}'"],"reqConfirms":1}' --abi ./SafeMultisigWallet.abi.json --sign ~/ton-keys/msig.keys.json --wc -1

#run node
./run.sh