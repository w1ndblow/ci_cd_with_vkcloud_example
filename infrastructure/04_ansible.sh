#!/bin/bash

source common.sh

echo "Введите github token:"
read github_token

github_owner=$(git remote -v | head -n 1 | cut -d ":" -f2 | cut -d "/" -f1) 
github_repo=$(git remote -v | head -n 1 | cut -d ":" -f2 | cut -d "/" -f2| cut -d "." -f1) 

run_command "ansible-playbook main.yml -i ../inventory -e github_owner=$github_owner -e github_repo=$github_repo -e github_authtoken=$github_token -v" "ansible"

