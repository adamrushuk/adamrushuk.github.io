---
title: Create an Azure Service Principal for Ansible Tower (AWX)
description: Create an Azure Service Principal for an Ansible Tower (AWX) Credential
categories:
  - ansible
  - azure
tags:
  - azure
  - ansible
  - ansible-tower
  - awx
  - cli
  - powershell
toc: true
toc_sticky: true
comments: true
excerpt: |
  You want to test Azure Provisioning using Ansible Tower (or the Open Source version, AWX) so you'll need a way to authenticate with Azure.
---

## Scenario

You want to test Azure Provisioning using Ansible Tower (or the Open Source version, AWX) so you'll need a way to authenticate with Azure.

## Solution

An Azure Service Principle will need to be created so that Ansible Tower can authenticate.

### Method 1: Azure CLI

1. Install the [Azure CLI](https://docs.microsoft.com/en-gb/cli/azure/install-azure-cli?view=azure-cli-latest).
1. Create an Azure Service Principal called `ansible` with the password `MyStrongPassw0rd!`
    ```bash
    az ad sp create-for-rbac --name ansible --password MyStrongPassw0rd!
    ```
1. This will return some JSON like the example below:
    ```bash
    {
    "appId": "abcd1234-abcd-efff-1234-abcd12345678",
    "displayName": "ansible",
    "name": "http://ansible",
    "password": "MyStrongPassw0rd!",
    "tenant": "12345678-ab12-cd34-ef56-1234abcd5678"
    }
    ```
1. The `appId` key above is referred to as the `client_id` for the Azure Credential in Ansible Tower.
1. The `password` key above is referred to as the `secret` for the Azure Credential in Ansible Tower.
1. The `tenant` key above is also referred to as the `tenant` for the Azure Credential in Ansible Tower.
1. To show your Azure Subscriptions, run the following
    ```bash
    > az account list --output table

    Name        CloudName    SubscriptionId                        State    IsDefault
    ----------  -----------  ------------------------------------  -------  -----------
    Free Trial  AzureCloud   aaaa1111-bbbb-cccc-abcd-aaabbbcccddd  Enabled  True
    ```
1. Note down your `SubscriptionId` for later use.

### Method 2: Azure PowerShell

1. Install the new [Azure PowerShell Module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-1.0.0):
    ```powershell
    Install-Module -Name Az -AllowClobber
    ```

1. Create an Azure Service Principal called `ansible` with the password `MyStrongPassw0rd!`:
    ```powershell
    $servicePrincipleName = 'ansible'
    $secureString = ConvertTo-SecureString 'MyStrongPassw0rd!' -AsPlainText -Force
    $azADApplicationParams = @{
        DisplayName    = $servicePrincipleName
        IdentifierUris = "http://$($servicePrincipleName)"
        Password       = $secureString
    }
    New-AzADApplication @azADApplicationParams -Verbose
    ```
1. This will return an object like this:
    ```bash
    DisplayName             : ansible
    ObjectId                : 11111111-2222-3333-abcd-12345678abcd
    IdentifierUris          : {http://ansible}
    HomePage                : 
    Type                    : 
    ApplicationId           : abcd1234-abcd-efff-1234-abcd12345678
    AvailableToOtherTenants : False
    AppPermissions          : 
    ReplyUrls               : {}
    ObjectType              : Application
    ```
1. The `ApplicationId` key above is referred to as the `client_id` for the Azure Credential in Ansible Tower.
1. To show your Azure Subscriptions, run the following
    ```bash
    Get-AzSubscription

    Name          Id                                   TenantId                             State  
    ----          --                                   --------                             -----  
    Pay-As-You-Go aaaa1111-bbbb-cccc-abcd-aaabbbcccddd 12345678-ab12-cd34-ef56-1234abcd5678 Enabled
    ```
1. Note down `Id` (Subscription ID) and `TenantId` for later use.

### Create an Azure Credential in Ansible Tower (AWX)

1. Navigate to the Credentials page, within the Resources menu.
1. Create a new Credential and ensure the `CREDENTIAL TYPE` field is `Microsoft Azure Resource Manager`.
1. Enter the previously created values into the `SUBSCRIPTION ID`, `CLIENT ID`, `CLIENT SECRET`, and `TENANT ID` fields as shown below:  
![Create Azure Credential](/assets/images/ansible-awx-azure-credential.png)
