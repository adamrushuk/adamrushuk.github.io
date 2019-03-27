---
title: Secure Azure Provisioning with Terraform Backend and Azure Key Vault
description: Secure Azure Provisioning with Terraform Backend and Azure Key Vault
categories: 
  - terraform
tags:
  - azure
  - terraform
  - hashicorp
  - powershell
toc: true
toc_sticky: true
comments: true
excerpt: |
  I needed a secure method of configuring Terraform so that plain text passwords were not readable. I also wanted to
  share the Terraform state with other collaborators, so they could work on the same Terraform configuration.
# header:
#   image: /assets/images/logos/logo-text-8c3ba8a6.svg
---

## Scenario

[Terraform](https://www.terraform.io/) is my favourite tool when provisioning resources in Azure. However, by
default Terraform saves a [local state file](https://www.terraform.io/docs/state/) (terraform.tfstate) that
includes sensitive data (passwords etc) in clear text. Another issue was other collaborators could not access my
state file.

I needed a secure method of configuring Terraform so that plain text passwords were not readable. I also wanted to
share the Terraform state with other collaborators, so they could work on the same Terraform configuration.

## Solution - TL;DR

If you don't care about the specifics, head over to my
[terraform-azure](https://github.com/adamrushuk/terraform-azure) GitHub repo and follow the step-by-step
instructions in the [README](https://github.com/adamrushuk/terraform-azure/blob/master/README.md).

## Solution - Full

### Terraform Backend for Azure

The solution to the above issues was to configure a
[standard Terraform Backend for Azure](https://www.terraform.io/docs/backends/types/azurerm.html), which offered
[State Storage and Locking](https://www.terraform.io/docs/backends/state.html).

However, it wasn't just as simple as creating the required resources in Azure:

1. a new Resource Group.
1. a new Storage Account.
1. a new Storage Container.

### Terraform Azure service principal

Even with those created, Terraform needed a way to access Azure:

1. [Create an Azure service principal](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli).
1. [Configure Terraform environment variables](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure#configure-terraform-environment-variables).

After creating the above Azure service principal, I wondered what the best method of storing that login information
until it was required. I initially created persistent environment variables, but quickly realised that was insecure
as any process could read those values at any time.

### Azure Key Vault

Enter the [Azure Key Vault](https://azure.microsoft.com/en-gb/services/key-vault/). Using the Key Vault, I was able
to store the Azure service principal details for Terraform, then load those Key Vault "secrets" into a PowerShell
session **only** when I wanted to use Terraform. The environment variables would disappear as soon as I closed
the PowerShell session. Happy days!

There were quite a few manual tasks to complete for all this to work, so I created two PowerShell scripts to do the
heavy lifting.

### Configure Azure For Secure Terraform Access Script

The [ConfigureAzureForSecureTerraformAccess.ps1](https://github.com/adamrushuk/terraform-azure/blob/master/scripts/ConfigureAzureForSecureTerraformAccess.ps1)
script configures Azure for secure Terraform access using Azure Key Vault.

The following steps are automated:

- Creates an Azure Service Principle for Terraform.
- Creates a new Resource Group.
- Creates a new Storage Account.
- Creates a new Storage Container.
- Creates a new Key Vault.
- Configures Key Vault Access Policies.
- Creates Key Vault Secrets for these sensitive Terraform login details:
    - ARM_SUBSCRIPTION_ID
    - ARM_CLIENT_ID
    - ARM_CLIENT_SECRET
    - ARM_TENANT_ID
    - ARM_ACCESS_KEY

### Load Azure Terraform Secrets to Environment Variables Script

The [LoadAzureTerraformSecretsToEnvVars.ps1](https://github.com/adamrushuk/terraform-azure/blob/master/scripts/LoadAzureTerraformSecretsToEnvVars.ps1)
script loads Azure Key Vault secrets into Terraform environment variables for the current PowerShell session.

The following steps are automated:

- Identifies the Azure Key Vault matching a search string (default: 'terraform-kv').
- Retrieves the Terraform secrets from Azure Key Vault.
- Loads the Terraform secrets into these environment variables for the current PowerShell session:
    - ARM_SUBSCRIPTION_ID
    - ARM_CLIENT_ID
    - ARM_CLIENT_SECRET
    - ARM_TENANT_ID
    - ARM_ACCESS_KEY

## Summary

By default, Terraform uses an insecure local state file, but configuring a Backend with the access credentials
saved in a Key Vault allows completely secure provisioning into Azure.

I've included an example Terraform configuration in my [terraform-azure](https://github.com/adamrushuk/terraform-azure)
GitHub repo, so just follow the README for instructions.
