
# Client Pod Egress Solution
We gonna use Istio to solve this problem: Un pod cliente que haga requests a distintos sitios web mediante el balanceador de carga. (ej. curl).
Why Istio?. Is very easy set up and solve the problem with this tool.

## ISTIO Installation
NOTE: Im using Kind as my kubernetes cluster provider


You need install the CLI of Istio running the following command

In MacOs: 
```bash 
brew install istioctl
```

Linux(Ubuntu): 
```bash 
curl -L https://istio.io/downloadIstio | sh - && cd istio-1.20.1 && export PATH=$PWD/bin:$PATH 
```
Now you have the CLI installed and, you can set up the Istio in your cluster. 

Install Istio in your cluster: 

```bash
istioctl install --set profile=demo -y
```
With the above command we already have the Istio egress gateway. Now, we can setup our egress rules for our pod.


### HTTP EGRESS SETUP

Already have .sh file called ```http-runner.sh``` to run all commands to set up the demo for HTTP Request.

Run the following commands to give permissions and run the .sh file:

```bash
chmod +x  ./http-runner.sh
./http-runner.sh
```

Find the client pod name running: 
```bash
kubectl get pod
```
You must got something like this:

```
NAME                    READY   STATUS    RESTARTS   AGE
sleep-f868c7945-857kx   2/2     Running   0     
```
where ```sleep-f868c7945-857kx``` is the pod name

Now, you are ready to test the pod making requests through our egress gateway egress.

Just run the following command:
```bash
kubectl exec sleep-f868c7945-857kx -c sleep -- curl -sSL -o /dev/null -D - http://edition.cnn.com/politics

...
HTTP/1.1 301 Moved Permanently
...
location: https://edition.cnn.com/politics
...

HTTP/2 200
Content-Type: text/html; charset=utf-8
...
```

Remember change the pod name


To cleanUp the HTTP test just run:


```bash
chmod +x  ./http-cleanup.sh
./http-cleanup.sh
```


### NETWORK POLICY

This section shows you how to create a Kubernetes network policy to prevent bypassing of the egress gateway. To test the network policy, you create a namespace, test-egress, deploy the sleep sample to it, and then attempt to send requests to a gateway-secured external service.

Already have .sh file called ```network-policy-spinup.sh``` to run all commands to set up this demo .

Run the following commands to give permissions and run the .sh file:

```bash
chmod +x  ./network-policy-spinup.sh
./network-policy-spinup.sh
```

Running the following command 
```bash
kubectl exec "$(kubectl get pod -n test-egress -l app=sleep -o jsonpath={.items..metadata.name})" -n test-egress -c sleep -- curl -v -sS https://edition.cnn.com/politics
```

 it should fail since the traffic is blocked by the network policy. Note that the sleep pod cannot bypass istio-egressgateway. The only way it can access edition.cnn.com is by using an Istio sidecar proxy and by directing the traffic to istio-egressgateway. This setting demonstrates that even if some malicious pod manages to bypass its sidecar proxy, it will not be able to access external sites and will be blocked by the network policy.
```
Hostname was NOT found in DNS cache
  Trying 151.101.65.67...
  Trying 2a04:4e42:200::323...
Immediate connect fail for 2a04:4e42:200::323: Cannot assign requested address
  Trying 2a04:4e42:400::323...
Immediate connect fail for 2a04:4e42:400::323: Cannot assign requested address
  Trying 2a04:4e42:600::323...
Immediate connect fail for 2a04:4e42:600::323: Cannot assign requested address
  Trying 2a04:4e42::323...
Immediate connect fail for 2a04:4e42::323: Cannot assign requested address
connect to 151.101.65.67 port 443 failed: Connection timed out
```

Now, you gonna set up the sidecar and some rules to allow the traffic through our egress running the following command:

```bash
chmod +x  ./inject-sidecard-proxy.sh
./inject-sidecard-proxy.sh
```

Now it should succeed since the traffic flows to egress-gateway in the istio-system namespace, which is allowed by the Network Policy you defined. egress-gateway forwards the traffic to edition.cnn.com running the following command:

```bash
kubectl exec "$(kubectl get pod -n test-egress -l app=sleep -o jsonpath={.items..metadata.name})" -n test-egress -c sleep -- curl -sS -o /dev/null -w "%{http_code}\n" https://edition.cnn.com/politics
```

You must received a ```200``` code
.

You can follow the Istio documentation to see this but in more detail in this [Documentation](https://istio.io/latest/docs/tasks/traffic-management/egress/egress-gateway/)