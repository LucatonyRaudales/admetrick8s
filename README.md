
# Admetricks Tech Test

El challenge is to set up a local Kubernetes cluster with the following services:

Three pods with a proxy that allows internet access and is only accessible through a load balancer using authentication (no IPs). Each proxy must have different authentication.

A load balancer pod with authentication for requests (can be based on headers) that handles both HTTP and HTTPS traffic. It should use the same entry authentication and, depending on its output, authenticate correctly with each proxy.

A client pod that makes requests to different websites through the load balancer.

A pod that monitors the resources used by the other pods.



## Documentation
We need have terraform and Kustomize Installed

## Terraform
Infrastructure automation to provision and manage resources in any cloud or data center.
[Documentation](https://www.terraform.io)

## Kustomize
Kustomize introduces a template-free way to customize application configuration that simplifies the use of off-the-shelf applications.
[Documentation](https://kustomize.io)

# Get Started
Let start with the installation, deployment and use of this solved tech test

## Load Balancer

To setup a load balancer in bare metal (locally) we gonna use MetalLB tools
[Documentation](https://metallb.universe.tf).
The configuration manifest is in this repo, so you only need a kubernetes cluster working on your machine and follow the next steps.

You have to enable strict ARP mode, running the following commands is the easy way:

```bash
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```
After that, You need to check on your LAN the available IP's and set it in configmap.yaml and pool.yaml file, in my case I have this IP's range: - 192.168.1.220-192.168.1.230 <- Available IP's range in my LAN.

To apply the manifest you have run:
```bash
kustomize build . | kubectl apply  -f -
```
NOTE: If you get any errors, you should wait a moment for the other settings to finish applying.


## Terraform Manifests
Now You need set up the terraform code running the following commands:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

NOTE: If you get any errors, wait a moment and apply again.

## Run Locally
To access to pods you need set up the hosts on you machine.

web-app.kubernetes.local => for common web app

monitor.kubernetes.local => monitor pod

To configure the hosts you need to know the IP assigned to your load balancer. To find out, run the following command:

```bash
  kubectl get service lb
```

You must got something like this:
```bash
  NAME   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
  lb     LoadBalancer   10.96.6.116   192.168.1.220   80:31442/TCP   27s
```

### Setting up hosts
where the IP of you load balancer is: ```192.168.1.220```

Now update you host file located in: ```/etc/hosts```

it must be something like this: 
```
##

# Host Database

#

# localhost is used to configure the loopback interface

# when the system is booting. Do not change this entry.

##
192.168.1.220 web-app.kubernetes.local
192.168.1.220 monitor.kubernetes.local
192.168.1.220 netdata.k8s.local
```

### Testing basic auth
after that you can access to the pods using hosts.
The nginx controller have setting up a basic authentication to allow the ingress to this pods.
The username and password are:

```
username: auth
password: admin
 ```

### Host alternative

 If you dont want to enable the hosts, just use port fordward running the following command:

 Monitor:  ```kubectl port-forward service/netdata  19999:19999```

 Web-app: ```kubectl port-forward service/lb 8080:80```

### Client Pod
 To test the client pod with requests to external service, follow the next instructions:

Run:
```bash
kubectl exec -it cliente-pod -- /bin/sh
curl https://pokeapi.co/api/v2/pokemon/ditto
```
