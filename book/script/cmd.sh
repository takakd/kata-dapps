#!/usr/bin/env zsh

SCRIPT_DIR=$(cd $(dirname "$0"); pwd)
DATA_DIR=${SCRIPT_DIR}/../private_net

usage(){
cat <<_EOT_
Usage:
  $0 Command

Example.
  $0 init

Command:
  init    Initialize Geth with genesis.json
  clear   Clean up
  run     Run Geth
_EOT_
exit 1
}

init() {
    geth --datadir  ${DATA_DIR}/ init ${SCRIPT_DIR}/../private_net/genesis.json
}

clear() {
  rm -r ${SCRIPT_DIR}/../private_net/geth
  rm -r ${SCRIPT_DIR}/../private_net/keystore
}

run() {
    ## 6.1.4.6: Run
    geth --networkid "33" --nodiscover --datadir $DATA_DIR --rpc --rpcaddr "localhost" --rpcport "8545" --rpccorsdomain "*" --rpcapi "eth,net,web3,personal" \
      --allow-insecure-unlock \
      --targetgaslimit "20000000" console 2>> ${DATA_DIR}/error.log

    ## 6.1.5.12: Run with password file
    # geth --networkid "33" --nodiscover --datadir $DATA_DIR --rpc --rpcaddr "localhost" --rpcport "8545" --rpccorsdomain "*" --rpcapi "eth,net,web3,personal" \
    #   --allow-insecure-unlock \
    #   --targetgaslimit "20000000" console 2>> ${DATA_DIR}/error.log \
    #   --unlock <addr1>,<addr2>,<addr3>... \
    #   --password $DATA_DIR/password.txt

    ## 7-1-3: Run on Remix IDE
    # geth --networkid "33" --nodiscover --datadir $DATA_DIR --rpc --rpcaddr "localhost" --rpcport "8545" --rpccorsdomain "*" --rpcapi "eth,net,web3,personal" \
    #   --rpc --rpccorsdomain https://remix.ethereum.org \
    #   --allow-insecure-unlock \
    #   --targetgaslimit "20000000" console 2>> ${DATA_DIR}/error.log \
    #   --unlock <addr1>,<addr2>,<addr3>... \
    #   --password $DATA_DIR/password.txt
}

if [[ $# -lt 1 ]]; then
    usage
fi

if [[ $1 = "init" ]]; then
    init
elif [[ $1 = "clear" ]]; then
    clear
elif [[ $1 = "run" ]]; then
    run
else
    usage
fi