---
title: Using the setproduct function in Terraform
description: Using the setproduct function in Terraform
categories:
  - terraform
tags:
  - terraform
  - hashicorp
toc: true
toc_sticky: true
comments: true
header:
  # image: /assets/images/image-filename.jpg
  # teaser: /assets/images/logos/PowerShell_5.0_icon_tall.png
excerpt: |
  I needed a way to create all possible combinations from two lists. The first was a list of Azure AD Roles, and the second was a list of target Resource Groups where the AAD Roles should be assigned.
---

## Scenario

I needed a way to create all possible combinations from two lists. The first was a list of Azure AD Roles, and the second was a list of target Resource Groups where the AAD Roles should be assigned.

## Solution

The solution was using [Terraform's built-in `setproduct` function](https://www.terraform.io/language/functions/setproduct).

> The setproduct function finds all of the possible combinations of elements from all of the given sets by computing the Cartesian product.

### Code Example

```bash
# Create all possible combinations from two lists, and loop through result to assign roles
# https://www.terraform.io/docs/language/functions/setproduct.html

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.20.0"
    }
  }
}

locals {
  roles = [
    "Storage Blob Data Owner",
    "Key Vault Contributor",
  ]
  scopes = [
    "/subscriptions/SUB_NAME/resourceGroups/rg1",
    "/subscriptions/SUB_NAME/resourceGroups/rg2",
  ]

  role_scopes_product = setproduct(local.roles, local.scopes)

  # Setproduct produces a structure like this for role_scopes_product:
  # [
  #   [
  #     "Storage Blob Data Owner",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg1",
  #   ],
  #   [
  #     "Storage Blob Data Owner",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg2",
  #   ],
  #   [
  #     "Key Vault Contributor",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg1",
  #   ],
  #   [
  #     "Key Vault Contributor",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg2",
  #   ],
  # ]


  # Build a map from the above "list of lists", using a compound key of both list values, and the map value being the original list of the role and scope
  role_scopes_map_of_lists = { for role_scope in local.role_scopes_product : "${role_scope[0]}-${role_scope[1]}" => role_scope }

  # role_scopes_map_of_lists looks like this:
  # {
  #   "Key Vault Contributor-/subscriptions/SUB_NAME/resourceGroups/rg1" = [
  #     "Key Vault Contributor",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg1",
  #   ]
  #   "Key Vault Contributor-/subscriptions/SUB_NAME/resourceGroups/rg2" = [
  #     "Key Vault Contributor",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg2",
  #   ]
  #   "Storage Blob Data Owner-/subscriptions/SUB_NAME/resourceGroups/rg1" = [
  #     "Storage Blob Data Owner",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg1",
  #   ]
  #   "Storage Blob Data Owner-/subscriptions/SUB_NAME/resourceGroups/rg2" = [
  #     "Storage Blob Data Owner",
  #     "/subscriptions/SUB_NAME/resourceGroups/rg2",
  #   ]
  # }


  role_scopes_map_of_maps = {
    for role_scope in local.role_scopes_product : "${role_scope[0]}-${role_scope[1]}" => {
        "role_name" = role_scope[0],
        "scope" = role_scope[1]
    }
  }

  # role_scopes_map_of_maps looks like this:
  # {
  #   "Key Vault Contributor-/subscriptions/SUB_NAME/resourceGroups/rg1" = {
  #     "role_name" = "Key Vault Contributor"
  #     "scope" = "/subscriptions/SUB_NAME/resourceGroups/rg1"
  #   }
  #   "Key Vault Contributor-/subscriptions/SUB_NAME/resourceGroups/rg2" = {
  #     "role_name" = "Key Vault Contributor"
  #     "scope" = "/subscriptions/SUB_NAME/resourceGroups/rg2"
  #   }
  #   "Storage Blob Data Owner-/subscriptions/SUB_NAME/resourceGroups/rg1" = {
  #     "role_name" = "Storage Blob Data Owner"
  #     "scope" = "/subscriptions/SUB_NAME/resourceGroups/rg1"
  #   }
  #   "Storage Blob Data Owner-/subscriptions/SUB_NAME/resourceGroups/rg2" = {
  #     "role_name" = "Storage Blob Data Owner"
  #     "scope" = "/subscriptions/SUB_NAME/resourceGroups/rg2"
  #   }
  # }
}

# resource groups
resource "azurerm_resource_group" "rg1" {
  name     = "rg1"
  location = "uksouth"
}

resource "azurerm_resource_group" "rg2" {
  name     = "rg2"
  location = "uksouth"
}

data "azurerm_client_config" "current" {}
data "azuread_service_principal" "current" {
  application_id = data.azurerm_client_config.current.client_id
}

# maps of lists loop example
resource "azurerm_role_assignment" "map_of_lists" {
  for_each             = local.role_scopes_map_of_lists
  scope                = each.value[1]
  role_definition_name = each.value[0]
  principal_id         = "MY_USER_ID"
}

# maps of maps loop example
resource "azurerm_role_assignment" "map_of_maps" {
  for_each             = local.role_scopes_map_of_maps
  scope                = each.value.scope
  role_definition_name = each.value.role_name
  principal_id         = data.azuread_service_principal.current.object_id
}
```

### Code Usage

Save the code example to a local file, then run the commands below view the data structures etc:

```bash
# init
terraform init

# enter console
terraform console

# output locals to view data structures
# show all list variations
local.role_scopes_product

# show the map of lists
local.role_scopes_map_of_lists

# show the nested map
local.role_scopes_map_of_maps

# exit console

# show plan
terraform plan
```
