---
title: Interactive debugging within a Jenkins container running on Kubernetes
description: Interactive debugging within a Jenkins container running on Kubernetes
categories: 
  - kubernetes
tags:
  - kubernetes
  - jenkins
  - packer
  - ansible
  - debug
toc: true
toc_sticky: true
comments: true
excerpt: |
  Popular DevOps tools like Packer and Ansible come with the ability to do interactive debugging, which is
  essential when troubleshooting issues quickly. However, what happens when you're running your CI pipelines on
  Kubernetes?
# header:
#   image: /assets/images/logos/logo-text-8c3ba8a6.svg
---

## Introduction

Popular DevOps tools like Packer and Ansible come with the ability to do interactive debugging, which is essential
when troubleshooting issues quickly.

However, what happens when you're running your CI pipelines on Kubernetes?

## Problem

The problem with running your CI pipelines on Kubernetes is that tools like Packer and Ansible dont allow
interactive debugging within containers using standard configuration, meaning "pause on error" functionality will
not work.

I'm not sure the exact reason why, but suspect it's to do with not having a terminal session attached, along with
other missing environment settings.

I've even seen issues where interactive debugging doesn't work *outside* of containers, like the
"[-on-error=ask and -debug doesn't prompt when using WSL](https://github.com/hashicorp/packer/issues/9170)" issue I
logged for Packer.

## Why debug within the pipeline?

Some may suggest the answer is to run these tools locally. Sure, both Packer and Ansible can run locally in your
favourite console without issue, but, what if your CI pipeline has several stages that change the environment
_before_ Packer and Ansible are used?

You can create scripts to mimick what your CI pipelines stages do, and prepare the environment accordingly, but
this will quickly become out-of-date, so just becomes extra maintainance.

## Scenario

I was working on a CI pipeline to build Golden Images, which could take an hour or more between builds. This was
painfully slow to develop and troubleshoot, as there were limited build attempts per day.

So, I started investigating methods on interactive debugging within a Kubernetes pipeline. My Google-fu failed me.
There was simple nothing out there.

## Solution

Here is the solution I came up with:

1. Install a terminal multiplexer (like `screen`) within the build container, which allowed sessions you can attach to:

    ```bash
    # part of Dockerfile
    # Install dependencies and utils
    apt-get update && apt-get install -y screen
    ```

1. Use Packer's new [`error-cleanup-provisioner`](https://www.packer.io/docs/templates/provisioners#on-error-provisioner) to pause the build:  
(**NOTE**: This provisioner will not run unless the normal provisioning run fails)

    ```json
    "error-cleanup-provisioner": {
        "type": "shell-local",
        "inline": [
            "echo 'Running [error-cleanup-provisioner] as an error occurred...'",
            "echo 'Sleeping for 2h...'",
            "sleep 2h"
        ]
    }
    ```

1. Connect to the build container within Kubernetes:

    ```bash
    # find Jenkins pod name
    podname=$(kubectl get pod --namespace jenkins -l jenkins=slave -o jsonpath="{.items[0].metadata.name}")

    # enter container shell
    kubectl exec --namespace jenkins -it "$podname" -- /bin/sh
    ```

1. Attach to the screen session:  
(**NOTE**: Initially, when you enter the container shell, you won't see any CI job environment changes)

    ```bash
    # show env vars
    # note the Jenkinfile job env vars are missing (eg: CI_DEBUG_ENABLED, and PACKER_*)
    printenv | sort | grep -E "CI_|PACKER"

    # list screen sessions
    screen -ls

    # attach detached session
    screen -r

    # show env vars
    # now Jenkins job env vars exist
    printenv | sort | grep -E "CI_|PACKER"
    ```

1. Use an interactive debugger, like the [Ansible playbook debugger](https://docs.ansible.com/ansible/latest/user_guide/playbooks_debugger.html).

    ```bash
    # set config
    export ANSIBLE_CONFIG="./ansible/ansible.cfg"

    # simple ping check
    ansible all -m ping --check --user packer -i /tmp/packer-provisioner-*

    # run playbook
    ansible-playbook ./ansible/playbook-with-error.yml -i /tmp/packer-provisioner-*
    ```

Visit my [debug-k8s-pipeline](https://github.com/adamrushuk/debug-k8s-pipeline) repo for the full code examples.
