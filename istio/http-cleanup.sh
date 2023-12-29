#!/bin/bash

kubectl delete gateway istio-egressgateway
kubectl delete serviceentry cnn
kubectl delete virtualservice direct-cnn-through-egress-gateway
kubectl delete destinationrule egressgateway-for-cnn
