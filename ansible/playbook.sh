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

# Create Random SSH User to complete install, and disable ssh afterwards
export INSTALL_USER=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-f0-9' | fold -w 10 | head -n 1)

# Export the IP Address to make it available to the ansible playbooks
export SERVER_ADDRESS="${IP}"

# Export the local folder name to make it available to the ansible playbooks
cd ..
mkdir -p configurations
export LOCAL_STORAGE="$(pwd)/configurations"
cd -

# It's a brand new server so let's skip this validation feature
export ANSIBLE_HOST_KEY_CHECKING=False

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

help() {
    echo "USAGE: ./playbook.sh [Private SSH Key Path] [IP Address of Server]"
    echo ""
    exit 1
}

create_inventory() {
    echo "${IP} ansible_ssh_private_key_file=${KEY} ansible_user=${SSH_AS}" > inventory
}

execute() {
    #rm -rf roles
    #ansible-galaxy install -p roles -f -r requirements.yml
    ansible-playbook -c ssh -i inventory site-01.yml
    echo "${IP} ansible_ssh_private_key_file=${KEY} ansible_user=${INSTALL_USER}" > inventory
    ansible-playbook -c ssh -i inventory site-02.yml
}

wait_for_ssh() {
    echo "Waiting for remote SSHD service to respond ..."
    while true; do
        ssh -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            ${SSH_AS}@${IP} -i ${KEY} \
            "echo 'connected!' " \
            && break
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

rm inventory
