---
title: Using Ansible and DSC with Windows
description: Using Ansible and DSC in a Windows environment
categories:
  - ansible
tags:
  - ansible
  - dsc
  - windows
  - centos
toc: true
toc_sticky: true
comments: true
excerpt: |
  For the past year or so I've been teaching my friend Steve about the many tools and techniques I've been using at work.
  We gradually built upon each topic until we had a working build for Exchange https://github.com/steevaavoo/ExchangeLab
  This all worked great as an example, but along the way we stumbled across several frustrations with DSC.
  We needed a solution that would overcome the above shortcomings of our current method using standard DSC / LCM.
---

**Updated: 2019-01-03** Changed CentOS Vagrant box to 7.6 and now using PIP for Ansible installation.

## Scenario

For the past year or so I've been teaching my friend [Steve](https://github.com/steevaavoo) about the many tools
and techniques I've been using at
work, including:

- Git
- Vagrant
- Packer
- PowerShell (various topics like Best Practices, Module Design, Build Automation)
- Desired State Configuration (DSC)

We gradually built upon each topic until we had a working build for Exchange:
[https://github.com/steevaavoo/ExchangeLab](https://github.com/steevaavoo/ExchangeLab)

This all worked great as an example, but along the way we stumbled across several frustrations with DSC:

- The tooling isn't as complete as other more mature Configuration Management solutions.
- Using DSC with the Local Configuration Manager (LCM) is not as flexible as other solutions.
- Getting runtime data is not easy. Eg.
  [Dynamically getting a certificate thumprint after creating it](https://github.com/steevaavoo/ExchangeLab/issues/3)
  
We needed a solution that would overcome the above shortcomings of our current method using standard DSC / LCM.

## Solution

[Ansible](https://www.ansible.com/) is a simple, agent-less configuration management tool, with excellent
[documentation](https://docs.ansible.com/) and [community support](https://www.ansible.com/community).

There are many more features available with Ansible, making it more flexible when building Playbooks (configurations).

I've created a repo for testing Ansible and DSC on Windows, with a view to port the current Exchange configuration over and add the missing functionality to the build.

### Ansible Control VM

Installing Ansible was as simple as adding the following few lines:

```bash
yum -y install epel-release --enablerepo=extras
yum -y update
yum -y install python-pip
pip install ansible --upgrade
pip install pywinrm
```

### Windows VMs

Building the Windows VMs also only required a few provisioning steps in their [Vagrantfile configuration](https://github.com/adamrushuk/Ansible-Windows/blob/master/Vagrantfile#L88-L94):

```bash
# Provisioning
# Reset Windows license
subconfig.vm.provision 'shell', inline: 'cscript slmgr.vbs /rearm //B //NOLOGO'
# Configure remoting for Ansible
subconfig.vm.provision 'shell', path: 'Vagrant/Scripts/ConfigureRemotingForAnsible.ps1'
# Reboot VM
subconfig.vm.provision :reload
```

**NOTE:** There were issues with the latest versions of VirtualBox (5.2.22) / Vagrant (2.2.1) during initial testing, where
the NIC adapters were not recognised, so I ended up using older versions using [Chocolatey](https://chocolatey.org/docs/installation#installing-chocolatey):

```powershell
choco install virtualbox --version 5.2.18
choco install vagrant --version 2.1.5
```

### Step by Step Build and Test Guide

Visit [https://github.com/adamrushuk/Ansible-Windows](https://github.com/adamrushuk/Ansible-Windows) and follow the step
by step [README](https://github.com/adamrushuk/Ansible-Windows/blob/master/README.md) to test Ansible with Windows locally using Vagrant and VirtualBox.

### Support

I'm happy to help with any questions or build errors, so please
[submit a new issue](https://github.com/adamrushuk/Ansible-Windows/issues/new) if you require any assistance.

### Acknowledgements

Although Ansible is easy to set up and configure, the simple Playbook examples and other tips were gathered from
the many excellent presentations by Trond Hindenes, and Matt Davis.

## What's Next?

Ansible is very powerful out of the box, yet some users may miss using a GUI, and other features like RBAC and
reporting.

[Ansible Tower](https://www.ansible.com/products/tower) is Red Hat's commercial solution to that problem, and they
also offer a free Open Source version called Ansible AWX:

> AWX is built to run on top of the Ansible project, enhancing the already powerful automation engine. AWX adds a
web-based user interface, job scheduling, inventory management, reporting, workflow automation, credential sharing,
and tooling to enable delegation.

Check out my next blog post where I [install Ansible AWX using Docker](https://adamrushuk.github.io/installing-ansible-awx-docker/).
