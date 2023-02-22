#!/bin/bash

source common.sh

run_command "tree terraform-k8s"

read

run_command "terraform init" "terraform-k8s"
