---
title: Get Product ID GUID Directly From MSI File
description: Easily get the Product ID / GUID directly from an MSI file, without installing it first.
categories:
  - powershell
tags:
  - powershell
  - msi
toc: false
comments: true
excerpt: |
  You need to find an MSI Product ID / GUID, but don't want to install it first.
---

## Scenario

You need to find an MSI Product ID / GUID, but don't want to install it first.

## Solution

The classic way to find an MSI Product ID / GUID is the install it first and interrogate the registry using code 
like this:

{% gist 34ad480bca761ad215a4adda73d448dc Get-ProductGuidRegistry.ps1 %}

However, there is an easier way that doesn't require installing the product first!

Simply update the path to your MSI file for `$msiPath` at the top of the following script:

{% gist 34ad480bca761ad215a4adda73d448dc Get-GuidFromMsiFile.ps1 %}

I can't take credit for the main code above, but thought I'd share as it's so useful.
