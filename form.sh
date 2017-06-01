#!/usr/bin/env bash

# ------------------------------------------------------------
# Google Cloud Terraform Wrapper
# ------------------------------------------------------------

# ------------------------------------------------------------
# Arguments
# ------------------------------------------------------------

# $1 - The subcommand to execute:
#       : create
#       : destroy

# ------------------------------------------------------------
# Configuration Sanity Test
# ------------------------------------------------------------

ID=$(cat config/config.tfvars | grep project_id | cut -d= -f2 | sed 's/"//g' | cut -d' ' -f2)
KEY=$(cat config/config.tfvars | grep private_key_path | cut -d= -f2 | sed 's/"//g' | cut -d' ' -f2)
GBINARY=$(which gcloud)
TBINARY=$(which terraform)
IP="Unknown"

# ------------------------------------------------------------
# Functions
# ------------------------------------------------------------

help1() {
    echo -e "USAGE: form.sh [command]"
    echo -e "\tAvailable Commands:"
    echo -e "\tcreate\t\t- To create the service in this project."
    echo -e "\tdestroy\t\t- To destroy the service in this project."
    echo ""
    exit 1
}

help2() {
    echo -e "You need to customize the configuration file in config/config.tfvars."
    echo -e "This means you'll have to create an empty google cloud project, and enter the details into this file."
    echo ""
    exit 1
}

help3() {
    echo -e "Required Software:"
    echo -e "1) Terraform"
    echo -e "\tVisit: https://www.terraform.io/"
    echo -e "2) Google Cloud SDK"
    echo -e "\tVisit: https://cloud.google.com/sdk/"
    echo -e ""
    exit 1
}

auth() {
    gcloud auth application-default login
    gcloud service-management enable cloudapis.googleapis.com
    gcloud service-management enable compute-component.googleapis.com
}

create() {
    terraform apply -var-file=config/config.tfvars terraform
    IP=$(terraform output ip)
}

destroy() {
    terraform destroy -var-file=config/config.tfvars terraform
}

function valid_ip()
{
    local  test=$1
    local  stat=1

    if [[ $test =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        test=($test)
        IFS=$OIFS
        [[ ${test[0]} -le 255 && ${test[1]} -le 255 \
            && ${test[2]} -le 255 && ${test[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Parse Arguments
[[ -z $1 ]] && help1
[[ -z $ID ]] && help2
[[ $ID == "mindful-audio-169214" ]] && help2
[[ -z $GBINARY ]] && help3
[[ -z $TBINARY ]] && help3

# Set the project ID
gcloud config set project "$ID"

case ${$1} in
*auth*)
    auth
    ;;
*create*)
    auth
    create
    if valid_ip $ip; then echo "Your VPN server is ready with ip address: $ip"; fi
    ;;
*create*)
    auth
    destroy
    ;;
*)
    echo "Unknown command '$1' ..."
    echo ""
    exit 2
    ;;
esac