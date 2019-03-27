---
title: Using VSTS Package Management for PowerShell Modules
description: How to create a VSTS feed for PowerShell Module management.
categories:
  - powershell
tags:
  - vsts
  - powershell
toc: true
toc_sticky: true
header:
  # image: /assets/images/image-filename.jpg
  # teaser: /assets/images/logos/PowerShell_5.0_icon_tall.png
excerpt: |
  I wanted to store my PowerShell Modules in VSTS and then install those modules during automated Builds / Release
---

## Scenario

I wanted to store my PowerShell Modules in VSTS and then install those modules during automated Builds / Releases.

## Solution

### Create a New Feed

1. [Install Package Management in VSTS from the Marketplace](https://marketplace.visualstudio.com/items?itemName=ms.feed#overview).  
  This is free for up to 5 users.
1. [Create a feed](https://docs.microsoft.com/en-gb/vsts/package/get-started-nuget) called `psmodules`:
  ![Create a feed](/assets/images/create-feed.png)
1. Once the new feed has been created, click `Connect to feed`.
1. Make a note of the Package source URL, eg. `https://ACCOUNTNAME.pkgs.visualstudio.com/_packaging/psmodules/nuget/v3/index.json`
1. We need to use a version 2 NuGet feed URL, so change the last part from `/v3/index.json` to `/v2` eg. `https://ACCOUNTNAME.pkgs.visualstudio.com/_packaging/psmodules/nuget/v2`

### Create a Personal Access Token (PAT)

1. [Create a PAT](https://docs.microsoft.com/en-gb/vsts/accounts/use-personal-access-tokens-to-authenticate).
1. Ensure you tick the following Authorized Scopes:  
  `Packaging (read and write), Packaging (read), Packaging (read, write, and manage)`.

![Select Authorized Scopes for packaging](/assets/images/pat-authorized-scopes.png)

### Register the Repository in PowerShell

Use the `Register-VstsFeedForPowerShellRepository.ps1` script I created below, following the comments for required variable changes:

{% gist 79c3a353e213d9b4c8d74c71b31a95a5 %}

### Known Issues

If you install and import the latest version of PowerShellGet (v1.6.0) you may get the following error when you try to use Publish-Module:

```powershell
Find-Module : A parameter cannot be found that matches parameter name 'AllowPrereleaseVersions'.
At C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.6.0\PSModule.psm1:1341 char:37
+             $currentPSGetItemInfo = Find-Module @FindParameters |
+                                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Find-Module], ParameterBindingException
    + FullyQualifiedErrorId : NamedParameterNotFound,Find-Module
```

I'm told this will be fixed soon, but in the meantime we can use PowerShellGet v1.5.0.0 which works as expected.
