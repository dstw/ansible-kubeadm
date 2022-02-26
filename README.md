# Ansible Playbook Kubeadm
Simple ansible playbook for built kubernetes cluster based on kubeadm.

## Features 

- Kubeadm
- Helm
- Metallb
- Grafana/Prometheus/Loki

## Prerequisites

- Ansible
- Physical/Virtual Server using Ubuntu 20.04

## Installation

- Setup Cluster:

``` bash
$ ansible-playbook node-create.yml
$ ansible-playbook site.yml
```

- Remove Cluster:
``` bash
$ ansible-playbook node-shutdown.yml
$ ansible-playbook node-remove.yml
```

## References
