# collectl
A robust perl application that collects ongoing performance data from various subsystems for playback and analysis.

This utility can be deployed to your [Red Hat OpenShift Container Platform 4](https://www.redhat.com/en/openshift-4) cluster to gather in-depth per-node performance metrics.

## Deployment
Prior to running any of the below commands, please ensure you have performed the steps in the [root of this project](../../README.md).

In addition, ensure you are performing all of the above steps in the `portworx-debug` project created by the above steps:
```bash
$ oc project portworx-debug
```


Once the build is completed, deploy the `Portworx Debug bundle`:
```bash
$ oc create -f portworx-debug.yaml
daemonset.apps/collectl created
```

To deploy `collectl` to nodes, find the node you intend to run `collectl` on:
```bash
$ oc get nodes
NAME                    STATUS   ROLES    AGE     VERSION
master-0.example.com    Ready    master   5h44m   v1.19.0+7070803
worker-0.example.com    Ready    worker   5h29m   v1.19.0+7070803
worker-1.example.com    Ready    worker   5h29m   v1.19.0+7070803
```

Then apply the `collectl` label to the node:
```bash
$ oc label node worker-0.example.com portworx-debug="true"
node/worker-0.example.com labeled
```

You should now see collectl running on the node:
```bash
$ oc get pods
NAME               READY   STATUS      RESTARTS   AGE
collectl-mnts4     1/1     Running     0          4m
```

You can run the px-collectl.sh script present on `/root/px-collectl.sh`

```bash
$ ./root/px-collectl.sh

```

## Customization
The `collectl` utility has a configuration file located at `/etc/collectl.conf`.  If you desire to customize anything about the collectl process, you may locally create a version of this file and add it as a `configMap` like so:
```bash
$ oc create configmap collectl-config --from-file collectl.conf
configmap/collectl-config created
```

If you do this, you will need to add your `configMap` to the `daemonSet.yaml` like so:
```yaml
      containers:
      - name: collectl
        image: image-registry.openshift-image-registry.svc:5000/portworx-debug/collectl
        imagePullPolicy: Always
        resources:
          limits:
            memory: 400Mi
          requests:
            cpu: 100m
            memory: 400Mi
        volumeMounts:
        - mountPath: /dev/mem
          name: mem
        - mountPath: /sys
          name: sys
        - mountPath: /var/log
          name: logs
        - mountPath: /etc/collect.conf
          name: collectl-config
        securityContext:
          runAsUser: 0
          privileged: true
      volumes:
      - name: mem
        hostPath:
          path: /dev/mem
          type: CharDevice
      - name: sys
        hostPath:
          path: /sys
          type: Directory
      - name: logs
        hostPath:
          path: /var/log
          type: Directory
      - name: config
        configMap:
          name: collectl-config 
```

Note in the above, there is a new `volumeMount` object and a new `volumes` object that corresponds to the `configMap` we have just created.

For help with setting values in the `/etc/collectl.conf`, refer to the [collectl documentation](http://collectl.sourceforge.net/).
