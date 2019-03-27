---
title: Azure Provisioning using Ansible AWX (Tower)
description: Azure Provisioning using Ansible AWX (Tower)
categories:
  - ansible
  - azure
tags:
  - azure
  - ansible
  - ansible-tower
  - awx
toc: true
toc_sticky: true
comments: true
excerpt: |
  You've installed and tested Ansible locally, then installed Ansible AWX (Open Source Ansible Tower) using Docker, and finally tested Ansible AWX with Windows Hosts.
  You now want to test Azure Provisioning using Ansible AWX.
---

## Scenario

You've [installed and tested Ansible locally](https://adamrushuk.github.io/ansible-dsc-windows/), then
[installed Ansible AWX (Open Source Ansible Tower) using Docker](https://adamrushuk.github.io/installing-ansible-awx-docker/),
and finally [tested Ansible AWX with Windows Hosts](https://adamrushuk.github.io/testing-ansible-awx-windows-hosts/).

You now want to test **Azure Provisioning** using **Ansible AWX**.

## Solution

Building upon the work I did in previous posts, I've created a pre-configured Vagrant lab that will build a local
Ansible Control VM on your computer.

You can then run a Job Template from the AWX Web UI to provision a CentOS VM and all associated resources in Azure.

### TL;DR - Step by Step Build and Test Guide

If you don't care how I built this Vagrant lab, simply visit [https://github.com/adamrushuk/ansible-azure](https://github.com/adamrushuk/ansible-azure)
and follow the step by step [README](https://github.com/adamrushuk/ansible-azure/blob/master/README.md) to test
Azure Provisioning using Ansible AWX.

If you'd like to know more, read on.

## Vagrant Lab

I used the latest CentOS Vagrant box ('bento/centos-7.6') for the base VM, and created several provisioning scripts, detailed below:

### install_common.sh

This script will:

1. Enable the EPEL repo
1. Install common utilities

{% gist aac1146af536e4648d5c7644d0beca10 install_common.sh %}

### install_ansible_azure.sh

This script will:

1. Install Ansible
1. Install Azure prereqs and modules

{% gist aac1146af536e4648d5c7644d0beca10 install_ansible_azure.sh %}

### install_docker_ce.sh

This script will:

1. Install Docker CE (required for Ansible AWX)

{% gist aac1146af536e4648d5c7644d0beca10 install_docker_ce.sh %}

### install_ansible_awx.sh

This script will:

1. Install Docker SDK for Python
1. Clone latest AWX repo
1. Stage custom AWX inventory config file
1. Install Ansible AWX
1. Install Ansible Tower CLI tool

{% gist aac1146af536e4648d5c7644d0beca10 install_ansible_awx.sh %}

### configure_ansible_awx.sh

This script will:

1. Create a new SSH key
1. Configure Ansible AWX using Tower CLI (SSL verification disabled)
1. Wait for AWX Web Server to be online
1. Wait for AWX Demo Data import to finish
1. Copy projects folder from Vagrant share into AWX project folder
1. Create an Azure Project resource in AWX
1. Create an Azure Inventory resource in AWX
1. Create an Azure Credential resource in AWX, using the Azure credentials from `azure_ansible_credentials.yml`
1. Create an Azure Job Template in AWX, using the above resources

{% gist aac1146af536e4648d5c7644d0beca10 configure_ansible_awx.sh %}

### azure_ansible_credentials.yml

This configuration file contains values needed for an Azure credential:

- `subscription` (your Azure Subscription ID)
- `client` (the Application ID from an Azure Service Principle)
- `secret` (the Password from an Azure Service Principle)
- `tenant` (your Azure Tenant ID)

{% gist aac1146af536e4648d5c7644d0beca10 azure_ansible_credentials.yml %}

## Support

I'm happy to help with any questions or build errors, so please
[submit a new issue](https://github.com/adamrushuk/ansible-azure/issues/new) if you require any assistance.
