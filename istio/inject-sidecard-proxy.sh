#!/bin/bash

kubectl label namespace test-egress istio-injection=enabled
kubectl delete deployment sleep -n test-egress
kubectl apply -f samples/sleep.yaml -n test-egress
kubectl apply -n test-egress -f policy/destination-rule.yaml