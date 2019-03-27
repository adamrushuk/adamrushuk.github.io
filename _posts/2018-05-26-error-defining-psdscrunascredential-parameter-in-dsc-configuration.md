---
title: Error defining PSDscRunAsCredential Parameter in DSC Configuration
description: If you define a parameter called 'PSDscRunAsCredential' in a DSC Configuration, you will get this error 'ConfigurationStatementToken System.ArgumentException An item with the same key has already been added'.
categories:
  - dsc
tags:
  - dsc
  - powershell
  - error
  - configuration-management
toc: false
toc_sticky: true
comments: true
excerpt: |
  The following error was occurring whilst testing a DSC Configuration 
  "An item with the same key has already been added"
---

## Scenario

The following error was occurring whilst testing a DSC Configuration:

```powershell
At line:1 char:15
+ Configuration Test {
+               ~~~~
ConfigurationStatementToken: System.ArgumentException: An item with the same key has already been added.
   at System.ThrowHelper.ThrowArgumentException(ExceptionResource resource)
   at System.Collections.Generic.Dictionary`2.Insert(TKey key, TValue value, Boolean add)   at System.Management.Automation.Language.Parser.ConfigurationStatementRule(IEnumerable`1 customAttributes, Token configurationToken)
```

![PSDscRunAsCredential Error](/assets/images/Error-PSDscRunAsCredential.png)

## Solution

### Do NOT add a parameter called PSDscRunAsCredential to a DSC Configuration

The error message made a bit more sense once I realised `PSDscRunAsCredential` should not be used as a parameter name,
but it would be more obvious if the `PSDscRunAsCredential` parameter itself was underlined.
