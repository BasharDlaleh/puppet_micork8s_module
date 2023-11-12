#!/bin/bash
microk8s enable dns &&
microk8s enable rbac &&
microk8s enable ingress &&
microk8s enable metrics-server &&
microk8s enable metallb &&
microk8s enable hostpath-storage