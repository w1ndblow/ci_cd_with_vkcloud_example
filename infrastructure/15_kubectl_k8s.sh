#!/bin/bash

source common.sh

export KUBECONFIG=infrastructure/k8s-cluster_kubeconfig.yaml




run_command "kubectl get all -n actions-runner-system" ".."

read

run_command "kubectl get all -n nginx-ingress" ".."

read
