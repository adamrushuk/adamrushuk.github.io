---
title: Installing Ansible AWX using Docker
description: Installing Ansible AWX using Docker within a Vagrant environment
categories:
  - ansible
tags:
  - ansible
  - ansible-tower
  - awx
  - docker
  - centos
toc: true
toc_sticky: true
comments: true
excerpt: |
  After installing Ansible to test within a Windows environment, I wanted to explore other methods of administering and using Ansible other than from the commandline.
---

## Scenario

After [installing Ansible to test within a Windows environment](https://adamrushuk.github.io/ansible-dsc-windows/),
I wanted to explore other methods of administering and using Ansible other than from the commandline.

## Solution

Although there was a commercial product called [Ansible Tower](https://www.ansible.com/products/tower) available
for testing, I wanted to explore the upstream project called AWX instead, as this had no licensing restrictions or
limits on how many nodes it could manage.

> AWX provides a web-based user interface, REST API, and task engine built on top of Ansible.

My [Vagrantfile](https://github.com/adamrushuk/Ansible-Windows/blob/master/Vagrantfile#L53-L60) installs Docker
and Ansible AWX during `vagrant up`, but I've included the steps below for reference.

### Installing Docker

Before installing Ansible AWX, Docker needs to be installed.

Use the script below to install the Extra Packages Repo and other useful utils if required:

{% gist b92f54b800002f968e8aa4da158610fb install_common.sh %}

Run the `install_docker_ce.sh` script below to install Docker CE:

{% gist b92f54b800002f968e8aa4da158610fb install_docker_ce.sh %}

### Installing Ansible AWX

Run the `install_ansible_awx.sh` script below to install Ansible AWX:

{% gist b92f54b800002f968e8aa4da158610fb install_ansible_awx.sh %}

Part of the `install_ansible_awx.sh` above copies an Inventory file used to configure Docker, Postgres, RabbitMQ,
and AWX. My configuration is shown below:

{% gist b92f54b800002f968e8aa4da158610fb inventory.ini %}

### Build Verification

Once the Vagrant build has finished, you can check the progress of the final import / migration tasks within
Docker by following the steps below:

1. From within the cloned repo folder (eg `~\Code\Ansible-Windows`), connect to the Ansible Control VM by running:
    ```bash
    vagrant ssh ansible01
    ```
1. List running containers:
    ```bash
    sudo docker ps
    ```
1. Tail the logs for the `awx_task` container:
    ```bash
    sudo docker logs -f awx_task
    ```
1. Once migrations are complete you will see messages like those shown below (amongst the many DEBUG messages):

```bash
# Initial migration log messages
Using /etc/ansible/ansible.cfg as config file
127.0.0.1 | SUCCESS => {
    "changed": false,
    "elapsed": 0,
    "path": null,
    "port": 5432,
    "search_regex": null,
    "state": "started"
}

... [logs removed for brevity]

Operations to perform:
  Apply all migrations: auth, conf, contenttypes, main, oauth2_provider, sessions, sites, social_django, sso, taggit
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying taggit.0001_initial... OK
  Applying taggit.0002_auto_20150616_2121... OK
  Applying contenttypes.0002_remove_content_type_name... OK


# Final migration log messages
Default organization added
Demo Credential, Inventory, and Job Template added
Successfully registered instance awx
Creating instance group tower
```

On my dev laptop it took ~20 mins for Ansible Control VM provisioning and build of Docker / Ansible AWX.

### Installation Error

During initial testing, my Ansible AWX installation failed with this error:

```bash
fatal: [localhost]: FAILED! => {
  "changed": false, 
  "msg": "Failed to import docker or docker-py - No module named 'requests.packages.urllib3'.
  Try pip install docker or pip install docker-py (Python 2.6)"
}
```

I had initially included `docker-python` and `docker-compose` in the installation scripts, so I removed these lines:

```bash
yum -y install docker-python
pip install docker-compose
```

I then added the [Docker SDK for Python](https://pypi.org/project/docker/) via PIP using:

```bash
pip install docker
```

## What's Next?

Check out my next blog post where I go over the steps for
[testing Ansible AWX with Windows hosts](https://adamrushuk.github.io/testing-ansible-awx-windows-hosts/).
