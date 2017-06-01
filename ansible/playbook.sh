#!/usr/bin/env bash

# ------------------------------------------------------------
# Ansible Playbook Wrapper
# ------------------------------------------------------------

# ------------------------------------------------------------
# Arguments
# ------------------------------------------------------------

# $1 - The path to the private key that will be used for SSH
# $2 - The IP of the remote host

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

KEY=$1
IP=$2
SSH_AS=root
export INSTALL_USER="cat /dev/urandom | tr -dc 'a-f0-9' | fold -w 10 | head -n 1"

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

help() {
    echo "USAGE: ./playbook.sh [Private SSH Key Path] [IP Address of Server]"
    echo ""
    exit 1
}

create_inventory() {
    echo "[ all ]" > inventory
    echo "${IP} ansible_ssh_private_key_file=${KEY} ansible_user=${SSH_AS}" >> inventory
}

execute() {
    ansible-galaxy install -r requirements.yml -p roles --force
    ansible-playbook -c ssh -i inventory site.yml
}

wait_for_ssh() {
    echo "Waiting for remote SSHD service to respond ..."
    while true; do
        ssh ${SSH_AS}@${IP} -i ${KEY} "echo 'connected!' " && break
        sleep 1
    done
    echo "Ready for Ansible!"
    echo ""
}

# Parse Arguments
[[ -z $1 ]] && help
[[ -z $2 ]] && help

wait_for_ssh
create_inventory
execute
