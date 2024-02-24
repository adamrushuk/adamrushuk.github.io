---
title: Configure Terraform's OpenID Connect (OIDC) authentication from GitLab CI to Azure
description: How to configure Terraform's OpenID Connect (OIDC) authentication from GitLab CI to Azure, for both the azurerm provider and the azurerm backend
categories: 
  - terraform
  - azure
tags:
  - terraform
  - azure
  - gitlab
  - oidc
toc: true
toc_sticky: true
comments: true
excerpt: |
  This post shows how to configure Terraform's OpenID Connect (OIDC) authentication from GitLab CI to Azure, for
  both the azurerm provider and the azurerm backend, which until recently was blocked by a known issue. The issue
  was fixed and released in v1.3.4.
header:
  image: /assets/images/logos/terraform_azure_gitlab.png
  teaser: /assets/images/logos/terraform_azure_gitlab.png
---

## Introduction

This post shows how to configure Terraform's OpenID Connect (OIDC) authentication from GitLab CI to Azure, for both
the [azurerm provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc)
***and*** the [azurerm backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm),
which until recently was blocked by a known issue. The [issue](https://github.com/hashicorp/terraform/issues/31802)
was fixed in [this PR](https://github.com/hashicorp/terraform/pull/31966) and released in
[`v1.3.4`](https://github.com/hashicorp/terraform/releases/tag/v1.3.4).

The following step-by-step instructions and code examples can be found in my
[terraform-oidc-azure-gitlab repo](https://gitlab.com/ARTestGroup99/terraform-oidc-azure-gitlab).

## Pre-reqs (Quick Start)

If you want to create all required resources in one go, ensure you have the
[Azure CLI](https://learn.microsoft.com/en-gb/cli/azure/) installed, then follow the steps below:

1. Open [`./scripts/setup.sh`](https://gitlab.com/ARTestGroup99/terraform-oidc-azure-gitlab/-/blob/main/scripts/setup.sh).
1. Update the variables to suit your environment (esp `GITLAB_PROJECT_PATH`).
1. Run `./scripts/setup.sh`.

Alternatively, read through each section below to review each step.

## Pre-reqs (Step-by-Step)

### Create Azure AD Application, Service Principal, and Federated Credential

```bash
# login
az login

# vars - update these with your own values
APP_REG_NAME='gitlab.com_oidc'
GITLAB_URL='https://gitlab.com'
GITLAB_PROJECT_PATH='<YOUR_GROUP_NAME>/<YOUR_PROJECT_NAME>'
GITLAB_PROJECT_BRANCH_NAME='main'

# create app reg / service principal
APP_CLIENT_ID=$(az ad app create --display-name "$APP_REG_NAME" --query appId --output tsv)
az ad sp create --id "$APP_CLIENT_ID" --query appId --output tsv

# create Azure AD federated identity credential
# subject examples: https://docs.gitlab.com/ee/ci/cloud_services/#configure-a-conditional-role-with-oidc-claims
APP_OBJECT_ID=$(az ad app show --id "$APP_CLIENT_ID" --query id --output tsv)

# example subject: project_path:ARTestGroup99/terraform-oidc-azure-gitlab:ref_type:branch:ref:main
cat <<EOF > cred_params.json
{
  "name": "gitlab-federated-identity",
  "issuer": "${GITLAB_URL}",
  "subject": "project_path:${GITLAB_PROJECT_PATH}:ref_type:branch:ref:${GITLAB_PROJECT_BRANCH_NAME}",
  "description": "GitLab federated credential for ${GITLAB_PROJECT_PATH}",
  "audiences": [
    "${GITLAB_URL}"
  ]
}
EOF

az ad app federated-credential create --id "$APP_OBJECT_ID" --parameters 'cred_params.json'
```

### Assign RBAC Role to Subscription

Run the code below to assign the `Contributor` RBAC role to the Subscription:

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az role assignment create --role "Contributor" --assignee "$APP_CLIENT_ID" --scope "/subscriptions/$SUBSCRIPTION_ID"
```

### Create Terraform Backend Storage and Assign RBAC Role to Container

Run the code below to create the Terraform storage and assign the `Storage Blob Data Contributor` RBAC role to the
container:

```bash
# vars - update these with your own values
PREFIX='arshzgl'
LOCATION='eastus'
TERRAFORM_STORAGE_RG="${PREFIX}-rg-tfstate"
TERRAFORM_STORAGE_ACCOUNT="${PREFIX}sttfstate${LOCATION}"
TERRAFORM_STORAGE_CONTAINER="terraform"

# resource group
az group create --location "$LOCATION" --name "$TERRAFORM_STORAGE_RG"

# storage account
STORAGE_ID=$(az storage account create --name "$TERRAFORM_STORAGE_ACCOUNT" \
  --resource-group "$TERRAFORM_STORAGE_RG" --location "$LOCATION" --sku "Standard_LRS" --query id --output tsv)

# storage container
az storage container create --name "$TERRAFORM_STORAGE_CONTAINER" --account-name "$TERRAFORM_STORAGE_ACCOUNT"

# define container scope
TERRAFORM_STORAGE_CONTAINER_SCOPE="$STORAGE_ID/blobServices/default/containers/$TERRAFORM_STORAGE_CONTAINER"
echo "$TERRAFORM_STORAGE_CONTAINER_SCOPE"

# assign rbac
az role assignment create --assignee "$APP_CLIENT_ID" --role "Storage Blob Data Contributor" \
  --scope "$TERRAFORM_STORAGE_CONTAINER_SCOPE"
```

## Create GitLab Repository Secrets

Create the following [GitLab CI/CD variables](https://docs.gitlab.com/ee/ci/variables/index.html) in
`https://gitlab.com/<GROUP_NAME>/<PROJECT_NAME>/-/settings/ci_cd`, using the code examples to show the required
values:

`ARM_CLIENT_ID`

```bash
# use existing variable from previous step
echo "$APP_CLIENT_ID"

# or use display name to get the app id
APP_CLIENT_ID=$(az ad app list --display-name "$APP_REG_NAME" --query [].appId --output tsv)
echo "$APP_CLIENT_ID"
```

`ARM_SUBSCRIPTION_ID`

```bash
az account show --query id --output tsv
```

`ARM_TENANT_ID`
  
```bash
az account show --query tenantId --output tsv
```

## Terraform OIDC Authentication

### Terraform Azurerm Backend

To enable OIDC authentication for the azurerm backend, apart from the standard
[azurerm backend configuration](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#example-configuration),
you must ensure you use at least Terraform version `1.3.4` as shown in the example below:

```hcl
terraform {
  required_version = ">= 1.3.4"

  backend "azurerm" {
    key = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.92.0"
    }
  }
}
```

Only the backend `key` is defined above, as I use the `-backend-config` options during `terraform init` which
allows passing variables, eg:

```bash
terraform init \
  -backend-config="resource_group_name=$TERRAFORM_STORAGE_RG" \
  -backend-config="storage_account_name=$TERRAFORM_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TERRAFORM_STORAGE_CONTAINER"
```

### Enable OIDC Authentication using GitLab Environment Variables

To enable OIDC authentication for both the azurerm backend and standard azurerm provider, use the following
GitLab CI `id_tokens` config and `variables` below:

```yaml
default:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.com
      
variables:
  ARM_USE_OIDC: "true"
  ARM_OIDC_TOKEN: $GITLAB_OIDC_TOKEN
```

To confirm OIDC authentication is being used, you can set the `TF_LOG` env var to `INFO`:

```yaml
variables:
  TF_LOG: "INFO"
```

## Running the Terraform Pipeline

Once all previous steps have been successfully completed, follow the steps below to run the `terraform` pipeline:

1. Navigate to your project's main page, eg `https://gitlab.com/<YOUR_GROUP_NAME>/<YOUR_PROJECT_NAME>`
1. In the left sidebar, click `Build > Pipelines`.
1. Above the list of pipeline runs, click `Run pipeline`.
1. (optional) Change the `ENABLE_TERRAFORM_DESTROY_MODE` variable value to `true` to run Terraform Plan in "destroy mode".
1. Click `Run pipeline`

## Clean Up

Run [`./scripts/cleanup.sh`](https://gitlab.com/ARTestGroup99/terraform-oidc-azure-gitlab/-/blob/main/scripts/cleanup.sh),
or use the code below to remove all created resources from this demo:

```bash
# login
az login

# vars - update these with your own values
APP_REG_NAME='gitlab.com_oidc'
PREFIX='arshzgl'

# remove role assignment
APP_CLIENT_ID=$(az ad app list --display-name "$APP_REG_NAME" --query [].appId --output tsv)
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
az role assignment delete --role "Contributor" --assignee "$APP_CLIENT_ID" --scope "/subscriptions/$SUBSCRIPTION_ID"

# remove app reg
echo "Deleting app [$APP_REG_NAME] with App Client Id: [$APP_CLIENT_ID]..."
az ad app delete --id "$APP_CLIENT_ID"

# list then remove resource groups (prompts before deletion)
QUERY="[?starts_with(name,'$PREFIX')].name"
az group list --query "$QUERY" --output table
for resource_group in $(az group list --query "$QUERY" --output tsv); do echo "Delete Resource Group: ${resource_group}"; az group delete --name "${resource_group}"; done
```
