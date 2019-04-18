---
title: An Example Azure DevOps Build Pipeline for PowerShell Modules
description: An example Azure DevOps Build Pipeline for PowerShell Modules
categories: 
  - azure-devops
tags:
  - azure-devops
  - azure
  - ci-cd
  - powershell
toc: true
toc_sticky: true
comments: true
excerpt: |
  Some excerpt test
# header:
#   image: /assets/images/logos/logo-text-8c3ba8a6.svg
---

## Introduction

I recently did a demo at the [Bristol WinOps Meetup](https://www.meetup.com/Bristol-WinOps-Meetup/events/256620903/)
showing an example Azure DevOps Build Pipeline for PowerShell Modules. I told everyone I'd get a blog post up "soon"
with more information, so here it is; better late than never!

I'll go over the goals for the example PowerShell Module, then break down the Build Pipeline tasks for Azure DevOps.

## Goals for the Example PowerShell Module (PSvCloud)

`PSvCloud` was a very old PowerShell module I started working on several years ago whilst I was using VMware vCloud
every day. I changed jobs shortly after starting it, so didn't add much. However, it was good enough as an example
module for the Azure DevOps Build Pipeline.

I applied the latest methods and best practices learned at the time to `PSvCloud`, with a focus on the process around  
[The Release Pipeline Model](https://msdn.microsoft.com/en-us/powershell/dsc/whitepapers#the-release-pipeline-model) (Source > Build > Test > Release).

### Source

Git was used with the practical [common flow](https://commonflow.org/) branching model.

### Build

[psake](https://github.com/psake/psake) was used to develop build scripts that can be used both locally using
[Task Runners in Visual Studio Code](https://code.visualstudio.com/docs/editor/tasks), and by a CI/CD system like
[Azure DevOps](https://azure.microsoft.com/en-gb/services/devops/).

This covers:

- Compiling separate function files into a single .psm1 module.
- Automatically updating documentation in Markdown, ready for a 3rd-party like
[ReadTheDocs](https://docs.readthedocs.io/en/latest/).

### Test

Testing the compiled code for known issues and ensuring it aligned to defined standards.

This covers:

- Code analysis using `PSScriptAnalyzer`.
- Code testing (unit, and common) using `Pester`.

### Release

Publishing the module build artifact to multiple Azure DevOps Artifacts (NuGet) feeds; one per environment. Each
environment shows the current version available using Status Badges:

![Status Badges](/assets/images/powershell-build-pipeline/build-status-badges.PNG)
