#!/bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED='\033[0;31m'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}/../terraform/cluster

printf "\n${BOLD}Deploying cluster... ${NORMAL} \n"
terraform init > /dev/null && terraform plan > /dev/null && terraform apply -auto-approve > /dev/null

if [ $? -eq 0 ]; then
    printf "   ${GREEN}Success! ${NOCOLOR} \n\n"
else
    echo "   ${RED}An error occured while deploying cluster${NOCOLOR}"
    exit
fi

# Getting useful variables (public IP adresses, security group id) from terraform output
MANAGER_IP=`echo "$(terraform output manager_public_ip)" | sed 's/["]//g'`
DATA_NODE_ONE_IP=`echo "$(terraform output data_node_one_public_ip)" | sed 's/["]//g'`
DATA_NODE_TWO_IP=`echo "$(terraform output data_node_two_public_ip)" | sed 's/["]//g'`
DATA_NODE_THREE_IP=`echo "$(terraform output data_node_three_public_ip)" | sed 's/["]//g'`
SECURITY_GROUP_ID=`echo "$(terraform output sg_id)" | sed 's/["]//g'`


cd ../..

printf "${BOLD}Setting up proxy config files... ${NORMAL}\n"
printf "   Sudo privileges are needed to create config files.\n"


# Putting public IP adresses in config file for proxy  
sudo echo "[IPADDRESSES]
master = ${MANAGER_IP}
slave_one = ${DATA_NODE_ONE_IP}
slave_two = ${DATA_NODE_TWO_IP}
slave_three = ${DATA_NODE_THREE_IP}
" > proxy/app/.conf/config.ini

sudo chmod 600 proxy/app/.conf/cluster-keypair.pem

zip -r terraform/proxy/user_data/proxy_app.zip proxy > /dev/null

printf "${BOLD}Deploying proxy...${NORMAL}\n"

cd terraform/proxy
terraform init > /dev/null && terraform plan > /dev/null && terraform apply -var "sg_id=${SECURITY_GROUP_ID}" -auto-approve > /dev/null

if [ $? -eq 0 ]; then
    PROXY_PUBLIC_IP=`echo "$(terraform output public_ip)" | sed 's/["]//g'`
    printf "   ${GREEN}Success! \n   API root:${NOCOLOR} ${PROXY_PUBLIC_IP}:8000 \n"
else
    printf "   ${RED}An error occured while deploying proxy. ${NOCOLOR}"
    exit
fi


