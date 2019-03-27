---
title: Using Packer for Automated Machine Images
description: Using Packer for Automated Machine Images
categories:
  - packer
tags:
  - packer
  - hashicorp
  - templates
  - images
  - build
  - automation
toc: true
comments: true
excerpt: |
  Before we get into the good stuff, let's just pause for a moment and remember the "old way" of managing templates.
---

Before we get into the good stuff, let's just pause for a moment and remember the "old way" of managing templates.

## The Old Way

When I first started managing VMs many years ago, I was a big fan of using templates to quickly spin them up in a known, pre-configured state.

Despite having this VM template feature available, it always baffled me how many people would still insist on manually installing the operating system and configuring applications; which I still see happen even today.

After a short while, configuring multiple templates were also taking too long for my liking, and I started looking at ways to improve this process further.

I ended up using multiple base images (for different use-cases) that I could occasionally power on, patch/update, install new software if required, then power down ready for a full clone before running sysprep.

Various scripts helped with some tasks, but there were still manual steps in the process and I'd be lying if I said mistakes were never made. There had to be a better way...

## The Packer Way

Enter [Packer](https://www.packer.io/) - the easy to use automated machine image builder tool.

There are many awesome features with Packer, but my favourite is the ability to create a single source configuration that can create **identical images** for **multiple platforms**. This is very powerful.

You can find some example Packer templates in my GitHub repository here: [https://github.com/adamrushuk/Packer-Templates](https://github.com/adamrushuk/Packer-Templates)

## Packer Templates

Packers uses simple JSON configuration files to create images, which you pass to the `build` command:

`packer build .\vb-win2012r2-base.json`

The JSON templates typically consist of three sections called `Builders`, `Provisioners`, and `Post-Processors`.

### Builders

Builders are responsible for creating machines and generating images from them for various platforms. For example, there are separate builders for EC2, VMware, VirtualBox, etc. Packer comes with many builders by default, and can also be extended to add new builders.

We'll be looking at the [virtualbox-iso](https://www.packer.io/docs/builders/virtualbox-iso.html) which is able to create VirtualBox virtual machines and export them in the OVF format, starting from an ISO image.

The OVF artifact will then feed into the [virtualbox-ovf](https://www.packer.io/docs/builders/virtualbox-ovf.html) for subsequent builds.

### Provisioners

Provisioners are used to configure the operating system, install patches/updates, and install required applications.

### Post-Processors

Post-processors run after the image is built by the builder and provisioned by the provisioner(s). Post-processors are optional, and they can be used to upload artifacts, re-package, or more.

We'll be using the `vagrant` post-processor to create [Vagrant](https://www.vagrantup.com/intro/index.html) boxes that can be used consistently throughout a team of developers.

### What's Next?

Next we'll look at a [Packer example to create a Windows image](https://adamrushuk.github.io/packer-example-windows/)...
