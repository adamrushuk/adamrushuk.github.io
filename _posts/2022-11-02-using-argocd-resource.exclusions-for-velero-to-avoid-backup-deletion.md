---
title: Using ArgoCD resource.exclusions for velero to avoid backup deletion during Velero upgrades
description: Using ArgoCD resource.exclusions for velero to avoid backup deletion during Velero upgrades
categories: 
  - kubernetes
tags:
  - kubernetes
  - argocd
  - gitops
  - velero
  - backup
toc: true
toc_sticky: true
comments: true
excerpt: |
  A quick tip on how to avoid backup deletion during Velero upgrades via Argo CD.
header:
  image: /assets/images/logos/k8s_aks.jpg
  teaser: /assets/images/logos/k8s_aks.jpg
---

## Introduction

A quick tip on how to avoid backup deletion during [Velero](https://velero.io/) upgrades via
[Argo CD](https://argo-cd.readthedocs.io/en/stable/).

## Problem

Initially when upgrading Velero with Argo CD, any backup objects created from a schedule would be pruned, as they
had no owner ref. Setting the schedule's `useOwnerReferencesInBackup` value to `true` within the
[Velero helm chart](https://github.com/vmware-tanzu/helm-charts/blob/68fc097c2b8997f5f6ab139dfb9f9ba11d154b47/charts/velero/values.yaml)
fixed that specific problem.

However, on subsequent Velero upgrades where the schedule was affected, _all_ backups would also be removed, due to
the `useOwnerReferencesInBackup` setting.

## Solution

The fix was to use Argo CD's [Resource Exclusion](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#resource-exclusioninclusion)
option, as shown below:

1. Edit the `argocd-cm` configmap:

    ```bash
    kubectl edit configmap argocd-cm --namespace argocd
    ```

1. Add exclusion block for velero backups:

    ```yaml
    data
      resource.exclusions: |
        - apiGroups:
          - "velero.io"
          kinds:
          - Backup
          clusters:
          - "*"
    ```
