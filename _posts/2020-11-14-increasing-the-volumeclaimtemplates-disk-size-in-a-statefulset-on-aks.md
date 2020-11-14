---
title: Increasing the volumeClaimTemplates Disk Size in a Statefulset on AKS
description: Increasing the volumeClaimTemplates Disk Size in a Statefulset on AKS
categories: 
  - kubernetes
tags:
  - kubernetes
  - aks
  - azure
toc: true
toc_sticky: true
comments: true
excerpt: |
  Last week I was tasked with increasing the size of some Persistent Volumes (PV) for one of the apps running on
  Azure Kubernetes Service (AKS). If possible, this task was to be completed without any downtime to the
  application.
header:
  image: /assets/images/logos/k8s_aks.jpg
  teaser: /assets/images/logos/k8s_aks.jpg
---

## Introduction

Last week I was tasked with increasing the size of some Persistent Volumes (PV) for one of the apps running on
Azure Kubernetes Service (AKS). If possible, this task was to be completed without any downtime to the
application.

I'd previously read about
[resizing persistent volumes](https://kubernetes.io/blog/2018/07/12/resizing-persistent-volumes-using-kubernetes/),
and knew about the `allowVolumeExpansion` setting within a `StorageClass`, so I was expecting this to be a breeze.

## Problem

After following the standard method above, I found that the Azure Disks were not expanding, even after deleting
and recreating the pods several times.

The reason was the AKS disk state was not changing to `Unattached`.

I've noted the main steps for two solutions below, but you can see my
[expand_k8s_pvc.sh](https://gist.github.com/adamrushuk/e36a79d2b29e00efee086a4c1f3999e2) gist for the full
code examples, which include installing an example application (`rabbitmq`), and additional validation steps.

## Solution 1: requires downtime

The first solution is the easiest, but requires downtime.

1. Use [Helm](https://helm.sh/docs/intro/install/) to install a `rabbitmq` cluster with `2` pods for testing:

    ```bash
    helm upgrade rabbitmq bitnami/rabbitmq --install --atomic --namespace rabbitmq --set=replicaCount=2 --set=persistence.size=1Gi --debug
    ```

1. Backup the statefulset YAML - needed to recreate afterwards:

    ```bash
    kubectl --namespace rabbitmq get statefulset rabbitmq --output yaml > rabbitmq-statefulset.yaml
    ```

1. Amend the exported `rabbitmq-statefulset.yaml` with the new
`volumeClaimTemplates.spec.resources.requests.storage` value (eg: from `1Gi` to `2Gi`).
1. Scale down statefulset to `0` replicas, and **wait** until all AKS disk states show: `Unattached`:

    ```bash
    kubectl --namespace rabbitmq scale statefulset rabbitmq --replicas=0
    ```

1. Delete the StatefulSet but leave its pod(s):

    ```bash
    kubectl --namespace rabbitmq delete statefulsets rabbitmq --cascade=false
    ```

1. Patch every PVC (`spec.resources.requests.storage`) in the StatefulSet, to increase its capacity (eg: from `1Gi` to `2Gi`):

    ```bash
    kubectl --namespace rabbitmq patch pvc data-rabbitmq-0 --patch '{\"spec\": {\"resources\": {\"requests\": {\"storage\": \"2Gi\"}}}}'
    kubectl --namespace rabbitmq patch pvc data-rabbitmq-1 --patch '{\"spec\": {\"resources\": {\"requests\": {\"storage\": \"2Gi\"}}}}'
    ```

1. Recreate using the exported/amended YAML from earlier:

    **WARNING!**: Ensure the exported `rabbitmq-statefulset.yaml` now has the new
    `volumeClaimTemplates.spec.resources.requests.storage` value (eg: `2Gi`), else adding new replicas will still
    use the old value of `1Gi`.
    {: .notice--warning}

    ```bash
    kubectl --namespace rabbitmq apply -f rabbitmq-statefulset.yaml
    ```

1. All pods should now be back online, with the attached PVCs showing the new disk capacity.
1. Validate the new disk size (`2Gi`) within application container:

    ```bash
    kubectl --namespace rabbitmq exec -it rabbitmq-0 -- df -h
    ```

## Solution 2: requires no downtime

The second solution has more steps, but requires **no** downtime.

1. Use [Helm](https://helm.sh/docs/intro/install/) to install a `rabbitmq` cluster with `3` pods for testing:

    ```bash
    helm upgrade rabbitmq bitnami/rabbitmq --install --atomic --namespace rabbitmq --set=replicaCount=3 --set=persistence.size=1Gi --debug
    ```

1. Backup the statefulset YAML - needed to recreate afterwards:

    ```bash
    kubectl --namespace rabbitmq get statefulset rabbitmq --output yaml > rabbitmq-statefulset.yaml
    ```

1. Amend the exported `rabbitmq-statefulset.yaml` with the new
`volumeClaimTemplates.spec.resources.requests.storage` value (eg: from `1Gi` to `2Gi`).
1. Delete the StatefulSet but leave its pod(s):

    ```bash
    kubectl --namespace rabbitmq delete statefulsets rabbitmq --cascade=false
    ```

1. Delete only first pod (second and third pods are still running), and **wait** until the first pod AKS disk state is `Unattached`:

    ```bash
    kubectl --namespace rabbitmq delete pod rabbitmq-0
    ```

1. Patch first pod PVC (`spec.resources.requests.storage`) in the StatefulSet, to increase its capacity (eg: from `1Gi` to `2Gi`):

    ```bash
    kubectl --namespace rabbitmq patch pvc data-rabbitmq-0 --patch '{\"spec\": {\"resources\": {\"requests\": {\"storage\": \"2Gi\"}}}}'
    ```

1. Recreate using the exported/amended YAML from earlier:

    **WARNING!**: Ensure the exported `rabbitmq-statefulset.yaml` now has the new
    `volumeClaimTemplates.spec.resources.requests.storage` value (eg: `2Gi`), else adding new replicas will still
    use the old value of `1Gi`.
    {: .notice--warning}

    ```bash
    kubectl --namespace rabbitmq apply -f rabbitmq-statefulset.yaml
    ```

1. Scale down statefulset to `1` replica, so the second and third pod is terminated, and **wait** until the pods AKS disk states are `Unattached`:

    ```bash
    kubectl --namespace rabbitmq scale statefulset rabbitmq --replicas=1
    ```

1. Patch second and third PVCs (`spec.resources.requests.storage`) in the StatefulSet, to increase its capacity (eg: from `1Gi` to `2Gi`):

    ```bash
    kubectl --namespace rabbitmq patch pvc data-rabbitmq-1 --patch '{\"spec\": {\"resources\": {\"requests\": {\"storage\": \"2Gi\"}}}}'
    kubectl --namespace rabbitmq patch pvc data-rabbitmq-2 --patch '{\"spec\": {\"resources\": {\"requests\": {\"storage\": \"2Gi\"}}}}'
    ```

1. Scale back to original replica amount, so the rabbitmq cluster can rebalance:

    ```bash
    kubectl --namespace rabbitmq scale statefulset rabbitmq --replicas=3
    ```

1. All pods should now be back online, with the attached PVCs showing the new disk capacity.
1. Validate the new disk space used within application container:

    ```bash
    kubectl --namespace rabbitmq exec -it rabbitmq-0 -- df -h
    ```

See my [expand_k8s_pvc.sh](https://gist.github.com/adamrushuk/e36a79d2b29e00efee086a4c1f3999e2) gist for the full
code examples.
