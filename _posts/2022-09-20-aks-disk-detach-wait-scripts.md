---
title: AKS Disk Detach Wait Scripts
description: PowerShell and Bash scripts that wait for an AKS disk to detach
categories: 
  - kubernetes
tags:
  - kubernetes
  - aks
  - azure
  - powershell
  - bash
toc: true
toc_sticky: true
comments: true
excerpt: |
  I had to automate some AKS tasks, which could only continue when disks had detached from their nodes. The solution
  should accept AKS cluster and PVC names, then wait for the disks to no longer show as Attached, and also be
  available in both PowerShell and Bash.
header:
  image: /assets/images/logos/k8s_aks.jpg
  teaser: /assets/images/logos/k8s_aks.jpg
---

## Problem

I had to automate some AKS tasks, which could only continue when disks had detached from their nodes. The solution
should accept AKS cluster and PVC names, then wait for the disks to no longer show as `Attached`, and also be
available in both PowerShell and Bash.

## PowerShell Solution

{% gist 3dabe2e45e1a6e0b29cc3d622476382a aks-disk-detach-wait.ps1 %}

## Bash Solution

{% gist 3dabe2e45e1a6e0b29cc3d622476382a aks-disk-detach-wait.sh %}
