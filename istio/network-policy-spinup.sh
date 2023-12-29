#!/bin/bash

kubectl create namespace test-egress
kubectl apply -n test-egress -f samples/sleep.yaml
kubectl label namespace istio-system istio=system
kubectl label ns kube-system kube-system=true
kubectl apply -n test-egress -f policy/just-kube-system-is-available-to-egress.yaml
