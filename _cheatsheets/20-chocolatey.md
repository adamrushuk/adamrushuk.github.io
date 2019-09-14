---
title: "Chocolatey Cheatsheet"
permalink: /cheatsheets/chocolatey/
toc: true
---

## Useful Links

- [Commands Reference](https://chocolatey.org/docs/commands-reference)
- [Package Repository](https://chocolatey.org/packages)

## Installing Chocolatey

Chocolatey installs in seconds. Just run the following command from an administrative PowerShell v3+ prompt (Ensure Get-ExecutionPolicy is not Restricted):

`Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression`

## List Installed Packages

`choco list --local-only`

## Install a Package

### Standard Package Installation

`choco install PACKAGENAME -y`

`choco install git -y`

### Multiple Package Installation

`choco install packer vagrant virtualbox git poshgit chefdk visualstudiocode -y`

### Ignore Checksums

I had to use this once for the GitHub package: [https://chocolatey.org/packages/GitHub](https://chocolatey.org/packages/GitHub)

`choco install github --ignore-checksums`

## Upgrade a Package

`choco upgrade <pkg|all> [<pkg2> <pkgN>] [<options/switches>]`

`choco upgrade git -y`

`choco upgrade all -y`

## Uninstall a Package

`choco uninstall PACKAGENAME`

`choco uninstall git --all-versions -y`

## List outdated packages

`choco outdated`
