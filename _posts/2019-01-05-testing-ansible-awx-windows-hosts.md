---
title: Testing Ansible AWX with Windows Hosts
description: Testing Ansible AWX with Windows Hosts
categories:
  - ansible
tags:
  - ansible
  - ansible-tower
  - awx
  - windows
toc: true
toc_sticky: true
comments: true
excerpt: |
    After installing Ansible AWX using Docker to test within a Windows environment, I wanted to configure and test Ansible AWX.
---

## Scenario

After [installing Ansible AWX using Docker to test within a Windows environment](https://adamrushuk.github.io/installing-ansible-awx-docker/),
I wanted to configure and test Ansible AWX.

## Solution

Although there is an excellent [Quick Setup Guide](https://docs.ansible.com/ansible-tower/latest/html/quickstart/index.html)
available for Ansible Tower (the commercial version of AWX), I'll be going over the steps I took to import files
from the already cloned repo ([https://github.com/adamrushuk/Ansible-Windows/](https://github.com/adamrushuk/Ansible-Windows/)).

### Copy Project Files

As AWX was installed using Docker, the Ansible files need copying into the default Project folder location
`/var/lib/awx/projects`, so the `hosts` Inventory file can be imported from inside the `awx_task` container.

1. From the root folder of the cloned Ansible-Windows repo, SSH into the Ansible Control VM:
    ```bash
    vagrant ssh ansible01
    ```
1. Switch to root user:
    ```bash
    sudo su
    ```
1. Navigate to the default Project folder location:
    ```bash
    cd /var/lib/awx/projects
    ```
1. Copy the whole ansible folder from the Vagrant share to the current projects folder:
    ```bash
    cp -R /vagrant/ansible/ ansible
    ```

The folder structure should be as shown below:  
![Ansible AWX Project folder](/assets/images/ansible-awx-project-folder.png)

### Log in to AWX Web Interface

1. Open a browser and navigate to the AWX login page [http://192.168.10.10](http://192.168.10.10).
1. Log in to AWX using the default username `admin` and default password `password`.

### Create a new Project

1. Navigate to the Projects page, within the Resources menu.
1. Create a new Project called `Manual Project`.
1. Ensure the `SCM TYPE` field is `Manual`.
1. The `PLAYBOOK DIRECTORY` drop-down menu should now show the `ansible` folder that was copied from the Vagrant
share in a previous step:
![Create a new Project in AWX](/assets/images/ansible-awx-new-project.png)

### Create a new Inventory

1. Navigate to the Inventories page, within the Resources menu.
1. Create a new Inventory called `Manual Project Inventory`:  
![Create a new Inventory in AWX](/assets/images/ansible-awx-new-inventory.png)

### Import Inventory File

Now the AWX Inventory called `Manual Project Inventory` has been created, the existing Inventory file called `hosts` can
be imported using the steps below:

1. From the Ansible Control VM command prompt, enter into the `awx_task` container's Bash shell:
    ```bash
    docker exec -it awx_task bash
    ```
1. Navigate to the `ansible` Project folder location that was previously copied:
    ```bash
    cd /var/lib/awx/projects/ansible
    ```
1. Import existing inventory file:
    ```bash
    awx-manage inventory_import --source=./hosts --inventory-name="Manual Project Inventory" --overwrite --overwrite-vars
    ```
1. The hosts from the imported inventory file now appear within the `Manual Project Inventory`:  
![Imported hosts](/assets/images/ansible-awx-imported-hosts.png)
1. The variables from the imported inventory file also appear within the `Manual Project Inventory`, though the
`ansible_user` and `ansible_password` variables should be removed, and a Credential created for this purpose:  
![Imported hosts](/assets/images/ansible-awx-imported-vars.png)

### Create a new Credential

As previously mentioned, the `ansible_user` and `ansible_password` variables have beed removed from the
`Manual Project Inventory`, so a new Credential is required:

1. Navigate to the Credentials page, within the Resources menu.
1. Create a new Credential called `Windows Hosts`.
1. Ensure the `CREDENTIAL TYPE` field is `Machine`.
1. Enter `vagrant` for both the username and password:  
![Windows Hosts Credential](/assets/images/ansible-awx-windows-hosts-credential.png)

### Create a new Job Template

All the previous resources are now selected within a Job Template:

1. Navigate to the Templates page, within the Resources menu.
1. Create a new Template called `Manual Job Template`.
1. Select `Manual Project Inventory` from the `INVENTORY` field search pop-up box.
1. Select `Manual Project` from the `PROJECT` field search pop-up box.
1. Select `site.yml` from the `PLAYBOOK` field drop-down menu.
1. Select `Windows Hosts` from the `CREDENTIALS` field search pop-up box.  

![Job Template](/assets/images/ansible-awx-job-template.png)

### Starting the Job Template

Once a Job Template has been created, it can be started by clicking the rocket icon highlighted below:  
![Job Template](/assets/images/ansible-awx-run-job-template.png)

### Reviewing the Job Logs

After the Job has finished, the logs can be viewed as shown below:  
![Job Logs](/assets/images/ansible-awx-job-logs.png)

## What's Next?

This post showed the mostly manual steps required for configuring and testing Ansible AWX. In future I will look
into the API and CLI configuration options.
