#!/bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED='\033[0;31m'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}/../terraform/standalone

# Deploys the standalone using terraform project
printf "\n${BOLD}Deploying MySQL standalone... ${NORMAL} \n"
terraform init > /dev/null && terraform plan > /dev/null && terraform apply -auto-approve > /dev/null

if [ $? -eq 0 ]; then
    printf "   ${GREEN}Success! ${NOCOLOR} \n"
else
    echo "   ${RED}An error occured while deploying MySQL standalone...${NOCOLOR}"
    exit
fi