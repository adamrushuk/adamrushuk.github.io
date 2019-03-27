---
title: Terraform vSphere Virtual Machine Customization Failed During Cloning
description: Terraform vSphere Virtual Machine Customization Failed During Cloning
categories:
  - terraform
tags:
  - terraform
  - hashicorp
  - vmware
toc: true
toc_sticky: true
comments: true
header:
  # image: /assets/images/image-filename.jpg
  # teaser: /assets/images/logos/PowerShell_5.0_icon_tall.png
excerpt: |
  Troubleshooting "Virtual machine customization failed" error during Terraform vSphere Cloning.
---

## Scenario

After [automating the build of a nested vSphere environment](https://adamrushuk.github.io/nested-vsphere-on-physical-esxi/),
I wanted to test [provisioning VMs in vSphere using Terraform](https://www.terraform.io/docs/providers/vsphere/r/virtual_machine.html).

I'd created a Windows VM with some basic network configuration, sysprep'd it and powered down ready for the
[single snapshot expected when using Linked-Clones with Terraform](https://www.terraform.io/docs/providers/vsphere/r/virtual_machine.html#linked_clone).

After taking that single snapshot on the target Windows VM, I created these Terraform configuration files to test
cloning: [https://github.com/adamrushuk/terraform-vsphere/tree/master/clone-windows-vm](https://github.com/adamrushuk/terraform-vsphere/tree/master/clone-windows-vm)

I tried to keep the configuration as basic as possible, but I kept getting the following error:

```bash
Error: Error applying plan:

1 error(s) occurred:

* vsphere_virtual_machine.vm: 1 error(s) occurred:

* vsphere_virtual_machine.vm:
Virtual machine customization failed on "/Datacenter/vm/DeployedVMs/winclone04":

An error occurred while customizing VM winclone04. For details reference the log file C:/Windows/TEMP/vmware-imc/guestcust.log in the guest OS.

The virtual machine has not been deleted to assist with troubleshooting. If
corrective steps are taken without modifying the "customize" block of the
resource configuration, the resource will need to be tainted before trying
again. For more information on how to do this, see the following page:
https://www.terraform.io/docs/commands/taint.html


Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```

## Solution

Looking through the Windows customization log file (`C:/Windows/TEMP/vmware-imc/guestcust.log`), I could see things
were taking longer than usual, and the network was not connecting.

It turns out the solution was [a simple one](https://github.com/terraform-providers/terraform-provider-vsphere/issues/388#issuecomment-427357809).

**DONT SYSPREP THE VM!**

During the VM clone, vSphere will sysprep the VM for you, so it doesn't expect the source VM to be sysprep'd already.
