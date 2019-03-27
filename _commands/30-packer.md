---
title: "Packer Commands"
permalink: /commands/packer/
toc: true
---

## Useful Links

- [Documentation](https://www.packer.io/docs/index.html)

## Installing Packer

[Chocolatey](https://adamrushuk.github.io/commands/chocolatey/) makes this a breeze:

`choco install packer -y`

## Validate JSON Template

### Validate Syntax and Configuration

`packer validate TEMPLATENAME.json`

### Validate Syntax Only

`packer validate -syntax-only TEMPLATENAME.json`

## Debugging

### Enable Logging to a File

This example uses PowerShell to set [environmental variables](https://www.packer.io/docs/other/environment-variables.html):

```powershell
# Set timestamp and environment vars
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$env:PACKER_LOG = 1
$env:PACKER_LOG_PATH = "packer-$($timestamp).log"

# Check environment vars
Get-ChildItem env: | Where-Object Name -match packer
```

### Enable Logging to STDERR Stream

`PACKER_LOG=1 packer build <config.json>`
