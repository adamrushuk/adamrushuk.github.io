---
title: Azure Credential Error When Adding to a Job Template via Ansible Tower CLI
description: Azure Credential Error When Adding to a Job Template via Ansible Tower CLI
categories:
  - ansible
  - azure
tags:
  - azure
  - ansible
  - ansible-tower
  - awx
  - cli
  - error
  - fix
toc: false
comments: true
excerpt: |
    Whilst I was working out how to automate Ansible Tower (AWX) using the [tower-cli command line tool](https://docs.ansible.com/ansible-tower/latest/html/towerapi/tower_cli.html)
    , I came across an error when trying to create a Job Template using a `Microsoft Azure Resource Manager`
    credential, and couldn't find a solution anywhere online.
---

## Problem

Whilst I was working out how to automate Ansible Tower (AWX) using the [tower-cli command line tool](https://docs.ansible.com/ansible-tower/latest/html/towerapi/tower_cli.html)
, I came across an error when trying to create a Job Template using a `Microsoft Azure Resource Manager`
credential, and couldn't find a solution anywhere online.

These were the steps I took leading up to the error:

1. First, I created an `AWX Project` using the following code:
    ```bash
    tower-cli project create --name "Azure Project" --description "Azure Playbooks" --scm-type "manual" --local-path "azure-linux-vm" --organization "Default"
    ```
1. An `AWX Inventory` was created for Azure, including a dynamically generated SSH key variable:
    ```bash
    tower-cli inventory create --name "Azure Inventory" --description "Azure Inventory" --organization "Default" --variables "ssh_public_key: \"$ssh_public_key\""
    ```
1. An `AWX Credential` was created for Azure, using the `Microsoft Azure Resource Manager` credential type, and referencing an Azure credential file:
    ```bash
    tower-cli credential create --name "Azure Credential" --description "Azure Credential" --organization "Default" --credential-type "Microsoft Azure Resource Manager" --inputs "@$azure_credential_file_path"
    ```
1. Lastly, I tried to create an `AWX Job Template` for Azure, referencing the previously created resources:
    ```bash
    tower-cli job_template create --name "Azure Resource Group" --description "Azure Resource Group - Job Template" --inventory "Azure Inventory" --project "Azure Project" --playbook "resource_group.yml" --credential "Azure Credential"
    ```

After the last step was actioned, I got the following error:

```bash
Error: The Tower server claims it was sent a bad request.

POST http://192.168.10.20/api/v2/job_templates/
Params: None
Data: {"job_type": "run", "playbook": "resource_group.yml", "description": "Azure Resource Group - Job Template", "inventory": 2, "credential": 2, "name": "Azure Resource Group", "project": 6}

Response: {"credential":["You must provide an SSH credential."]}
```

## Solution

The workaround was to initially create the Job Template using the `Demo Credential` which uses the `Machine`
credential type:

```bash
tower-cli job_template create --name "Azure CentOS Linux VM" --description "Azure CentOS Linux VM - Job Template" --inventory "Azure Inventory" --project "Azure Project" --playbook "centos_vm.yml" --credential "Demo Credential"
```

I was then able to add the `Microsoft Azure Resource Manager` credential to the new Job Template afterwards using:

```bash
tower-cli job_template associate_credential --job-template "Azure CentOS Linux VM" --credential "Azure Credential"
```
