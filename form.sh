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
GBINARY=$(command -v gcloud)
GBINARY_VERSION=$(gcloud version | grep 246.0.0)
TBINARY=$(command -v terraform)
IP="Unknown"

echo $ID

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
    echo -e "1) Terraform (gcloud provider version 2.12.0)"
    echo -e "\tVisit: https://www.terraform.io/"
    echo -e "2) Google Cloud SDK (version 246.0.0)"
    echo -e "\tVisit: https://cloud.google.com/sdk/"
    echo -e ""
    exit 1
}

auth() {
    gcloud auth login
    echo "Enabling cloud apis ..."
    gcloud services enable cloudapis.googleapis.com
    echo "Enabling compute apis ..."
    gcloud services enable compute.googleapis.com
}

create() {
    rm -rf configuration
    terraform init terraform
    terraform apply -var-file=config/config.tfvars terraform
    IP=$(terraform output ip)
}

destroy() {
    terraform init terraform
    terraform destroy -var-file=config/config.tfvars terraform
}

# Parse Arguments
[[ -z $1 ]] && help1
[[ -z $ID ]] && help2
[[ -z $GBINARY ]] && help3
[[ -z $TBINARY ]] && help3
[[ -z $GBINARY_VERSION ]] && help3

# Set the project ID
gcloud config set project "$ID"

case ${1} in
*auth*)
    auth
    ;;
*create*)
    auth
    create
    if [[ -e configurations/client1.ovpn ]]; then
        echo "Configuration files were downloaded successfully, you are ready to setup your client!"
    else
        echo "Configuration files were not generated, please recheck your config settings and try again!"
        echo "(To start over first run './form.sh destroy' to delete any resources that were created.)".
    fi
    ;;
*destroy*)
    auth
    destroy
    ;;
*)
    help1
    echo ""
    echo "Unknown command '$1' ..."
    echo ""
    exit 2
    ;;
esac
