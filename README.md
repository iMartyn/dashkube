# dashkube
A script and kubernetes configs to fire url events on dash button presses (great for domoticz)

This is entirely written in bash so it's full of vulnerabilities but c'mon, it's for when you have a home lab running kube and you have your dash buttons on the same LAN segment as that home lab...

First, find the mac address of you button, then add it to the CSV in the `configmap.yaml`
There are many ways to do this but here's what the script is using (needs root on a linux box)
```BASH
tcpdump -v -i eth0 -n port 67 and port 68 -l -A
```
(and press the button to see the output)

Once you've got the mac address in the configmap with a url, just deploy them :
```BASH
kubectl apply -f deploy.yaml
kubectl apply -f configmap.yaml
```

It's pretty much that simple.

Stuff that should be done :
- Make the bash a little more defensive
- Make the interface configurable (if your lab's actual ethernet is not eth0 you're SOL)

Tips :
- The curl command is just executed as `curl "$URL"` so if you want to do clever payload stuff, you could set your URL to have quotes in it and pass arguments in there.  The script only checks for `^$MAC,http` and accepts it, so have fun with shell injection!