#!/usr/bin/env bash

ID=$(cat config/config.tfvars | grep project_id | cut -d= -f2 | sed 's/"//g' | cut -d' ' -f2)

[[ -z $ID ]] && echo "You must supply a full gcloud project_id as an argument." && exit 1

gcloud auth application-default login
gcloud config set project "$ID"
gcloud service-management enable cloudapis.googleapis.com
gcloud service-management enable compute-component.googleapis.com
