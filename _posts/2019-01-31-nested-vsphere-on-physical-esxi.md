---
title: Automate Creating a Nested vSphere Environment on a Physical ESXi Host
description: Automate Creating a Nested vSphere Environment on a Physical ESXi Host
categories:
  - vmware
tags:
  - powershell
  - vmware
  - vsphere
  - esxi
toc: true
toc_sticky: true
comments: true
excerpt: |
  I wanted to quickly build a vSphere environment so I could test provisioning and configuration with other tools
  like Terraform and Ansible.

  I had an old desktop PC lying around with 32GB RAM and several SSDs, so decided to use that.
---

## Scenario

I wanted to quickly build a vSphere environment so I could test provisioning and configuration with other tools
like Terraform and Ansible.

I had an old desktop PC lying around with 32GB RAM and several SSDs, so decided to use that.

## Solution

### Preparation

First, I prepared the physical ESXi server using the following steps:

1. Download the latest ESXi ISO from VMware.
1. [Create a Bootable ESXi Installer USB Flash Drive](https://www.virten.net/2014/12/howto-create-a-bootable-esxi-installer-usb-flash-drive/).
1. Install ESXi.
1. [Configure a static IP address](https://msptechs.com/how-to-configure-static-ip-on-vmware-esxi-6-7/) for you local network (I chose `10.0.0.20/24`)

### Deployment Script

After asking in various Slack channels and searching online, I ended up on William Lam's excellent blog where he
goes over his vSphere deployment scripts: [https://www.virtuallyghetto.com/2016/11/vghetto-automated-vsphere-lab-deployment-for-vsphere-6-0u2-vsphere-6-5.html](https://www.virtuallyghetto.com/2016/11/vghetto-automated-vsphere-lab-deployment-for-vsphere-6-0u2-vsphere-6-5.html)

See the Requirements section for the download links.

### Issues

I downloaded and ran the `vsphere-6.7-vghetto-standard-lab-deployment.ps1` script a few times but ran into a few
issues that I needed to overcome.

#### Import-VApp Invalid URI The hostname could not be parsed

The first issue was OVF imports for nested ESXi VMs were failing. Luckily the
[issue had been logged](https://github.com/lamw/vghetto-vsphere-automated-lab-deployment/issues/15) and the
workaround was to expand the OVA and specify the OVF file path instead.

#### VCSA Hanging During Configuration

Looking at the import log (eg: `C:\Users\admin\AppData\Local\Temp\vcsaCliInstaller-2019-01-12-18-10-o2k_llt3\workflow_1547320219985`)
I could see it was still configuring itself, but it wasn't initially clear what the issue was.

There were DNS lookups going on, but I didn't have a DNS server in my lab. After installing a Domain Controller on
the physical ESXi server, I pointed to that as my DNS server and the VCSA configuration completed without issue.

During troubleshooting I also changed the default `$VCSADeploymentSize` from `tiny` to `small`.

## Final Lab Configuration

After making a few tweaks, the [modifed script](https://github.com/adamrushuk/vghetto-vsphere-automated-lab-deployment/blob/master/vsphere-6.7-vghetto-standard-lab-deployment.ps1) was able to create a nested vSphere lab environment in under 25 mins.

### HOSTS File Entries

Here's the HOST file entries I added for local name resolution from my admin workstation:

```
10.0.0.20	pesxi01.lab.local
10.0.0.30	dc01.lab.local
10.0.0.50	vcsa.lab.local
10.0.0.51	vesxi01.lab.local
10.0.0.52	vesxi02.lab.local
10.0.0.53	vesxi03.lab.local
```

### Computers

Here are the network settings I had to manually configure _before_ running the deployment script:

#### admin01 (my workstation)

- **IP**: 10.0.0.10
- **SM**: 255.255.255.0
- **GW**: none

#### pesxi01 (physical ESXi host)

- **UI**: https://pesxi01.lab.local/ui/
- **IP**: 10.0.0.20
- **SM**: 255.255.255.0
- **GW**: none

#### dc01 (domain controller)

- **IP**: 10.0.0.30
- **SM**: 255.255.255.0
- **GW**: none

### User Accounts

The deployment script creates the following user accounts:

#### pESXi01 root user

- root
- Pa55word!

#### vCenter admin user

- administrator@vsphere.local
- Pa55word!
