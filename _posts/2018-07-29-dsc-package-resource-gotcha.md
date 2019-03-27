---
title: DSC Package Resource Gotcha
description: Covers a gotcha found using the DSC Package resource when there is a trailing space in Package Name.
categories:
  - dsc
tags:
  - dsc
  - powershell
  - gotcha
  - msi
toc: false
comments: true
excerpt: |
  This quick post covers a gotcha I found using the DSC Package resource.
  I was having issues installing the Microsoft SQL Server 2012 Native Client (Direct Download http://go.microsoft.com/fwlink/?LinkID=239648&clcid=0x409) like so.
---

## Scenario

This quick post covers a gotcha I found using the DSC Package resource.

I was having issues installing the `Microsoft SQL Server 2012 Native Client` (Direct Download: 
http://go.microsoft.com/fwlink/?LinkID=239648&clcid=0x409) like so.

```PowerShell
Package 'Sqlncli'
{
    Ensure    = 'Present'
    Name      = 'Microsoft SQL Server 2012 Native Client'
    Path      = 'C:\Path\To\Files\sqlncli.msi'
    ProductId = '49D665A2-4C2A-476E-9AB8-FCC425F526FC'
    Arguments = "/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES"
    LogPath   = 'C:\Path\To\Logs\Sqlncli.log'
    DependsOn = '[Package]ReportViewer'
}
```

## Solution

After using the code from the previous post, I noticed there was a trailing space for the Package Name 
`Microsoft SQL Server 2012 Native Client`. The DSC Package resource doesn't do any trimming of the returned string 
for Package Name - nor should it have to - so the fault really lies with the MSI Author.

Anyway, it's one to watch out for but can be resolved by adding the trailing space as shown below:

```PowerShell
Package 'Sqlncli'
{
    Ensure    = 'Present'
    Name      = 'Microsoft SQL Server 2012 Native Client ' # note the required trailing space
    Path      = 'C:\Path\To\Files\sqlncli.msi'
    ProductId = '49D665A2-4C2A-476E-9AB8-FCC425F526FC'
    Arguments = "/qn /norestart IACCEPTSQLNCLILICENSETERMS=YES"
    LogPath   = 'C:\Path\To\Logs\Sqlncli.log'
    DependsOn = '[Package]ReportViewer'
}
```
