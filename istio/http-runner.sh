#!/bin/bash

kubectl apply -f <(istioctl kube-inject -f samples/sleep.yaml)
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})
kubectl apply -f http-traffic/service-entry.yaml
kubectl apply -f http-traffic/gateway.yaml
kubectl apply -f http-traffic/virtual-service.yaml


