---
title: Running KinD in GitLab CI on Kubernetes
description: Running KinD in GitLab CI on Kubernetes
categories: 
  - kubernetes
tags:
  - kubernetes
  - gitlab
toc: true
toc_sticky: true
comments: true
excerpt: |
  Whilst working on a Helm Chart pipeline, I wanted to bring together many of the testing steps I've used in other
  pipelines. This included validation, linting, and installing.

  The problem was the Helm Chart test pipeline required a nested Kubernetes environment, as our self-hosted GitLab
  runs on Kubernetes. DinD (Docker in Docker) and KinD (Kubernetes in Docker) solved the nested requirement, but
  errors were occuring.
header:
  image: /assets/images/logos/gitlab_helm_k8s.png
  teaser: /assets/images/logos/gitlab_helm_k8s.png
---

## Introduction

[GitLab CI/CD](https://docs.gitlab.com/ee/ci/) is a tool built into [GitLab](https://about.gitlab.com/) for
software development through the continuous methodologies.

GitLab CI is configured via the [.gitlab-ci.yml file](https://docs.gitlab.com/ee/ci/yaml/gitlab_ci_yaml.html), and
the [.gitlab-ci.yml reference documentation](https://docs.gitlab.com/ee/ci/yaml/README.html) is excellent. The
overall GitLab documentation is some of the best out there, however, not all use-cases for using GitLab CI are
covered.

Whilst working on a Helm Chart pipeline, I wanted to bring together many of the testing steps I've used in other
pipelines. This included validation, linting, and installing.

## Problem

The problem was the Helm Chart test pipeline required a nested Kubernetes environment, as our self-hosted
GitLab runs on Kubernetes. DinD (Docker in Docker) and KinD (Kubernetes in Docker) solved the nested requirement,
but errors were occurring.

## Solution

### Custom GitLab Runner

The solution was to configure a custom [GitLab Runner](https://gitlab.com/gitlab-org/charts/gitlab-runner) with four
volumes:

1. docker-certs: `/certs/client` (secure TLS connection)
1. dind-storage: `/var/lib/docker`
1. hostpath-modules: `/lib/modules`
1. hostpath-cgroup: `/sys/fs/cgroup`

The relevant GitLab Runner config is shown below:

```yaml
runners:
  config: |
    [[runners]]
      [runners.kubernetes]
        image = "ubuntu:20.04"
        privileged = true
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"
      [[runners.kubernetes.volumes.empty_dir]]
        name = "dind-storage"
        mount_path = "/var/lib/docker"
      [[runners.kubernetes.volumes.host_path]]
        name = "hostpath-modules"
        mount_path = "/lib/modules"
        read_only = true
        host_path = "/lib/modules"
      [[runners.kubernetes.volumes.host_path]]
        name = "hostpath-cgroup"
        mount_path = "/sys/fs/cgroup"
        host_path = "/sys/fs/cgroup"
  tags: "dind"
```

I've uploaded the full
[helm chart values for Docker-in-Docker (DinD) config to support installing KinD nodes](https://github.com/adamrushuk/charts/blob/main/charts/gitlab-runner-dind/values.yaml).

For more information, read the [GitLab documentation on using volumes with the GitLab Runner's Kubernetes executor](https://docs.gitlab.com/runner/executors/kubernetes.html#using-volumes).

### GitLab CI Configuration

With the custom GitLab Runner configured with the required four volumes, the following `.gitlab-ci.yml`
configuration was used for the Helm Chart pipeline (some code removed for brevity):

```yaml
# Helm Chart Pipeline
image: <HELM_RELEASE_PIPELINE_IMAGE>

variables:
  # When using dind service, we need to instruct docker to talk with
  # the daemon started inside of the service. The daemon is available
  # with a network connection instead of the default
  # /var/run/docker.sock socket.
  # port 2375 for no TLS connection (insecure)
  # port 2376 for TLS connection
  DOCKER_HOST: tcp://docker:2376

  # Specify to Docker where to create the certificates, Docker will
  # create them automatically on boot, and will create
  # `/certs/client` that will be shared between the service and job
  # container, thanks to volume mount from config.toml
  DOCKER_TLS_CERTDIR: "/certs"
  
  # These are usually specified by the entrypoint, however the
  # Kubernetes executor doesn't run entrypoints
  # https://gitlab.com/gitlab-org/gitlab-runner/-/issues/4125
  DOCKER_TLS_VERIFY: 1
  DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"

  # Disable 'shallow clone'
  GIT_DEPTH: 0

services:
  # service image (eg: svc-0) - contains docker daemon (engine)
  - docker:19.03.13-dind

# Use variables to decide what triggers the pipeline
# https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
workflow:
  rules:
    # https://docs.gitlab.com/ee/ci/yaml/README.html#workflowrules
    # Only trigger on a Merge Request
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    # Allow manual trigger via the GUI
    - if: '$CI_PIPELINE_SOURCE == "web"'

stages:
  - validate
  - lint
  - install

validate:
  tags:
    - dind
  stage: validate
  parallel:
    matrix:
      - K8S_VERSION:
          - 1.17.17
          - 1.18.15
          - 1.19.7
  script:
    - echo "this is the validate stage"

lint:
  tags:
    - dind
  stage: lint
  script:
    - echo "this is the linting stage"

install:
  before_script:
    - echo "Waiting for docker cli to respond before continuing build..."
    - |
      for i in $(seq 1 30); do
          if ! docker info &> /dev/null; then
              echo "Docker not responding yet. Sleeping for 2s..." && sleep 2s
          else
              echo "Docker ready. Continuing build..."
              break
          fi
      done

  tags:
    - dind
  stage: install
  parallel:
    matrix:
      - K8S_VERSION:
          - 1.17.17
          - 1.18.15
          - 1.19.7
  script:
    - echo "this is the install stage that uses KinD, eg:"
    - kind create cluster --name "ci-cluster${K8S_VERSION}" --image "kindest/node:v${K8S_VERSION}" --wait 5m
```

Note the `install.before_script` that waits for docker to be responsive. Without that check, the `install` job will
fail intermittently.
