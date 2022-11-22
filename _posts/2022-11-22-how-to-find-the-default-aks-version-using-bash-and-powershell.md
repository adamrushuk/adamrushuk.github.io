---
title: How to find the default AKS version using Bash and PowerShell
description: Bash and PowerShell examples for showing the default AKS version
categories: 
  - aks
tags:
  - aks
  - azure
  - bash
  - kubernetes
  - powershell
toc: true
toc_sticky: true
comments: true
excerpt: |
  I always wondered how the default AKS version was selected via the Azure portal, so worked out Bash and
  PowerShell examples for showing the default AKS version via the command-line.
header:
  image: /assets/images/logos/k8s_aks.jpg
  teaser: /assets/images/logos/k8s_aks.jpg
---

I always wondered how the default AKS version was selected via the Azure portal until I recently read this in the
[docs](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#azure-portal-and-cli-versions):

> When you deploy an AKS cluster with Azure portal, Azure CLI, Azure PowerShell, the cluster defaults to the N-1
> minor version and latest patch. For example, if AKS supports 1.17.a, 1.17.b, 1.16.c, 1.16.d, 1.15.e, and 1.15.f,
> the default version selected is 1.16.c.

Even though there are ways to [auto-upgrade existing AKS clusters](https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster)
I typically use Terraform to provision clusters, so I prefer to have more control over what version to use -
and more importantly - when the upgrades occur.

Read on to see Bash and PowerShell examples for showing the default AKS version via the command-line.

## Show the default AKS version using Bash

```bash
# show all aks versions
az aks get-versions --location 'uksouth'

# show default aks version using a JMESPath query
# https://learn.microsoft.com/en-us/cli/azure/query-azure-cli?tabs=concepts%2Cbash
az aks get-versions --location 'uksouth' --output 'tsv' --query 'orchestrators | [?default].orchestratorVersion'

# show default aks version using jq
az aks get-versions --location 'uksouth' | jq -r '.orchestrators | .[] | select(.default==true) | .orchestratorVersion'
```

## Show the default AKS version using PowerShell

```powershell
# show all aks versions
Get-AzAksVersion -location 'uksouth'

# show default aks version
(Get-AzAksVersion -location 'uksouth' | Where-Object default).OrchestratorVersion

# show default aks version using az cli
((az aks get-versions --location 'uksouth' | ConvertFrom-Json).orchestrators | Where-Object default).OrchestratorVersion
```
