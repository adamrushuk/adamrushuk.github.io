---
title: Packer Example for Windows
description: A Packer Example for Windows
categories:
  - packer
tags:
  - packer
  - hashicorp
  - templates
  - images
  - build
  - automation
  - windows
toc: true
toc_sticky: true
comments: true
excerpt: |
    You can get started quickly by using Packer's simple getting started guide, but you'll soon want to delve into the documentation for more options and examples.
    Let's install it and create our first image!
---

## Getting Started

You can get started quickly by using Packer's simple [getting started guide](https://www.packer.io/intro), but you'll soon want to delve into the [documentation](https://www.packer.io/docs/index.html) for more options and examples.

Let's install it and create our first image!

You can find all example files in my GitHub repository here: [https://github.com/adamrushuk/Packer-Templates](https://github.com/adamrushuk/Packer-Templates)

## Installation

Using [Chocolatey](https://adamrushuk.github.io/cheatsheets/chocolatey/), installing Packer is as easy as running:

`choco install packer -y`

Clone my GitHub repository if you want to follow along:

`git clone git@github.com:adamrushuk/Packer-Templates.git`

## TL;DR - Shut up and give me the goods!

If you really just want to see Packer in action, make sure you've cloned the git repository in the Installation step above, then run the [Invoke-Packer.ps1](https://github.com/adamrushuk/Packer-Templates/blob/master/Invoke-Packer.ps1) wrapper script: `.\Invoke-Packer.ps1`

If you're interested in the step-by-step breakdown, read on!

## Step 1: Create the base image

First we'll create a base image by passing our [first JSON template](https://github.com/adamrushuk/Packer-Templates/blob/master/vb-win2012r2-base.json) to the `build` command:

`packer build .\vb-win2012r2-base.json`

### Breakdown

The above command starts the build process in the following order:

**Builders Section**

1. Packer first checks the `packer_cache` folder to see if the ISO specified in `ISO URL` has already been downloaded. If not, it downloads the ISO.
1. The `output_directory` folder is checked to see if empty, or can be overwritten if `packer build -force <JSONTemplate>` was used.  
    This check is ignored if **-force** is used, eg: `packer build -force <JSONTemplate>`.
1. A VM is created in VirtualBox with the specified hardware settings.
1. A virtual floppy disk is attached containing the files specified in `floppy_files`.
1. The VM is powered on.
1. As Windows boots for the first time it notices `Autounattend.xml` in the root of the floppy drive, which actions several steps including:
    1. Selecting the `Windows Server 2012 R2 STANDARD` OS version.
    1. Creating a local user account called `vagrant` and adding it to the local `administrators` group.
    1. Executing the `a:\Boxstarter.ps1` script.
1. The `a:\Boxstarter.ps1` script installs `Chocolatey` and `Boxstarter`, then executes the `a:\Package.ps1` script.
1. The `a:\Package.ps1` script:
    1. Enables Remote Desktop.
    1. Installs critical Windows Updates.
    1. Removes the pagefile.
    1. Updates Firewall and enables WinRM.
1. Packer connects via WinRM and moves on to the Provisioners Section.

**Info:** Boxstarter will log all package activity output to `$env:LocalAppData\Boxstarter\boxstarter.log` on the guest. [TBC]
{: .notice--info}

**Warning:** `winrm_timeout` must be set high enough to account for the Windows Updates which can take 4hrs+. I've now set to `12h`, as my first build failed.
{: .notice--danger}

**Provisioners Section**

1. `Install-VirtualBoxGuestAdditions.ps1` is the only script used in this section, which simply installs the [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) software.

**Shutdown**

After the Provisioners section is complete, the shutdown command executes:

`shutdown /s /t 10 /f /d p:4:1 /c "Packer Shutdown"`

The resulting artifacts of `.ovf` and `.vmdk` VM files should be saved in the specified `output_directory`: `output-win2012r2-base`.

This step took ~4 hours.

## Step 2: Create the PowerShell 5 image

Now let's create another image with PowerShell 5 installed by passing our [second JSON template](https://github.com/adamrushuk/Packer-Templates/blob/master/vb-win2012r2-powershell5.json) to the `build` command:

`packer build .\vb-win2012r2-powershell5.json`

Having images for both PowerShell 4 and PowerShell 5 will enable us to target both versions when running our tests using a product like [Test-Kitchen](https://docs.chef.io/kitchen.html).

### Breakdown

The above command starts the build process in the following order:

**Builders Section**

1. The `output_directory` folder is checked to see if empty.  
    This check is ignored if **-force** is used, eg: `packer build -force <JSONTemplate>`.
1. The `source_path` folder is checked to see if the specified OVF file exists, eg: `output-win2012r2-base/win2012r2-base.ovf`.
1. A VM is created in VirtualBox by importing the `output-win2012r2-base/win2012r2-base.ovf` file from Step 1 (Create the base image).
1. The VM is powered on and Packer connects via WinRM.

**Provisioners Section**

1. `Install-PowerShell5.ps1` simply installs PowerShell 5: `choco install powershell -y`.
1. `windows-restart` ensures the VM is rebooted after the PowerShell 5 installation.
1. `cleanup.ps1` will:
    1. Remove temp folders/files.
    1. Remove unwanted Windows Update files.
    1. Defrag the C drive.
    1. Zero out freespace.

**Shutdown**

After the Provisioners section is complete, the shutdown command executes:

`shutdown /s /t 10 /f /d p:4:1 /c "Packer Shutdown"`

The resulting artifacts of `.ovf` and `.vmdk` VM files should be saved in the specified `output_directory`, eg: `output-win2012r2-powershell5`.

This step took ~20 minutes.

## Step 3: Sysprep and export to a Vagrant box

The final step is to sysprep the previous two images (from Steps 1 and 2) and export them to a Vagrant box - though I'll just cover one example using the image from Step 2.

Let's pass the [third JSON template](https://github.com/adamrushuk/Packer-Templates/blob/master/vb-win2012r2-export-vagrant.json) to the `build` command:

`packer build .\vb-win2012r2-export-vagrant.json`

### Breakdown

The above command starts the build process in the following order:

**Builders Section**

1. The `output_directory` folder is checked to see if empty.  
    This check is ignored if **-force** is used, eg: `packer build -force <JSONTemplate>`.
1. The `source_path` folder is checked to see if the specified OVF file exists, eg: `output-win2012r2-powershell5/win2012r2-powershell5.ovf`.
1. A VM is created in VirtualBox by importing the `./output-win2012r2-powershell5/win2012r2-powershell5.ovf` file from Step 2 (Create the PowerShell 5 image).
1. A virtual floppy disk is attached containing the files specified in `floppy_files`.
1. The VM is powered on and Packer connects via WinRM.

**Provisioners Section**

1. `Set-Sysprep.ps1` is the only script used in this section, which completes these two actions:
    1. Copies `a:\UK-postunattend.xml` to `C:\Windows\Panther\Unattend\unattend.xml`
    1. Copies `a:\SetupComplete-2012.cmd` to `C:\Windows\setup\scripts\SetupComplete.cmd`

These two files are used once the Vagrant box is powered on for the first time **after** the sysprep during the Packer shutdown.

`unattend.xml` configures:
1. Locale and language settings to `en-GB`.
1. Timezone to `GMT Standard Time`.
1. A local user account called `vagrant` and adding it to the local `administrators` group.
1. Various annoying GUI settings to be disabled.

`SetupComplete.cmd` simple enables WinRM: `netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow`, as the Packer shutdown command below disables WinRM.

**Shutdown**

After the Provisioners section is complete, the shutdown command executes:

`a:/PackerShutdown.bat` which will disable WinRM so Vagrant doesn't get confused during the first reboot after the sysprep:

```batch
REM Disable WinRM
call winrm set winrm/config/service/auth @{Basic="false"}
call winrm set winrm/config/service @{AllowUnencrypted="false"}
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

:: Sysprep and shutdown
C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/Panther/Unattend/unattend.xml /quiet /shutdown
```

The resulting artifacts of `.ovf` and `.vmdk` VM files should be saved in the specified `output_directory`: `/output-win2012r2-powershell5-vagrant`.

**Post-processors Section**

The `vagrant` post-processor will action the following:

1. Import the `.ovf` and `.vmdk` artifacts from the `provisioner` section.
1. Produce a Vagrant box using the `windows-template.vagrantfile` template.
1. As `"keep_input_artifact": true` is specified, the `.ovf` and `.vmdk` VM files from the `provisioner` section will be retained, but you can set this to false if preferred. I like to keep them for troubleshooting if required.

This step took ~20 minutes.

## Summary

We've gone over the separate steps you can take to create Packer images, and after about 5 hours you should now have a shiny new Vagrant box to play with: `Win2012R2-Std-WMF5-Full.box`

Now you can build upon these templates and customise to your liking.

### Reference

Make sure you visit these awesome blogs to see where most of the examples / scripts came from:

- [http://www.hurryupandwait.io/blog/creating-windows-base-images-for-virtualbox-and-hyper-v-using-packer-boxstarter-and-vagrant](http://www.hurryupandwait.io/blog/creating-windows-base-images-for-virtualbox-and-hyper-v-using-packer-boxstarter-and-vagrant)
- [https://hodgkins.io/best-practices-with-packer-and-windows](https://hodgkins.io/best-practices-with-packer-and-windows)
