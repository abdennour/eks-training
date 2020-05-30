Upgrading  the EKS TF Module from 10.0.0 to 12.0.0 is an  upgrade of EKS from 1.15 to 1.16


# Release Notes

- [terraform-aws-eks][1]
- [EKS 1.16 Release Notes][2]
- [Kubernetes 1.16 Release  Notes][3]

# Breaking Changes - Deprecated APIs Removed

>  [REFERENCE][4]

1. **NetworkPolicy** `apiVersion: extensions/v1beta1` is removed.
Instead, `apiVersion: networking.k8s.io/v1` must be used.

2. **PodSecurityPolicy** `apiVersion: extensions/v1beta1` is removed. 
Instead, `apiVersion: policy/v1beta1` must be used.

3. **Daemonset** `apiVersion:extensions/v1beta1` and `apiVersion: apps/v1beta2` are removed.
Instead, `apiVersion: apps/v1` must be used.
* `spec.templateGeneration` is removed
* `spec.selector` is required and immutable after creation
* `spec.updateStrategy.type` now defaults to RollingUpdate 

4. **Deployment** `extensions/v1beta1`, `apps/v1beta1`, and `apps/v1beta2` are removed.
Instead, `apiVersion: apps/v1` must be used.
* `spec.rollbackTo` is removed
* `spec.selector` is now required and immutable after creation
* ....

5. **StatefulSet** in the `apps/v1beta1` and `apps/v1beta2` API are removed.
Instead, `apiVersion: apps/v1` must be used.
* `spec.selector` is now required and immutable after creation
* ....

6. **ReplicaSet** in the `extensions/v1beta1`, `apps/v1beta1`, and `apps/v1beta2` API are removed.
Instead, `apiVersion: apps/v1` must be used.
* spec.selector is now required and immutable after creation






# Pre-upgrade Steps ----------------
>  [REFERENCE][5]

## I. Identify Removed API Versions
1. check resources that must be in `apps/v1` api version

```sh
# replicaset is usually updated when you update the parent resource
k get deployment,daemonset,statefulset --all-namespaces \
  -o go-template \
  --template='{{range .items}}{{printf "%s:%s(%s) %s -- helmRelease: %s\n" .apiVersion .kind .metadata.namespace .metadata.name .metadata.labels.release }}{{end}}'
```


2. check resources that must be in `networking.k8s.io/v1` api version

```sh
# NetworkPolicies
k get netpol --all-namespaces \
  -o go-template \
  --template='{{range .items}}{{printf "%s:%s(%s) %s\n" .apiVersion .kind .metadata.namespace .metadata.name }}{{end}}'
```


3. check resources that must be in `policy/v1beta1` api version

```sh
# PodSecurityPolicy
k get psp --all-namespaces \
  -o go-template \
  --template='{{range .items}}{{printf "%s:%s(%s) %s\n" .apiVersion .kind .metadata.namespace .metadata.name }}{{end}}'
```

## II. Replace Removed API Versions

- IF the resource belong to your **own Helm Chart**, update the Helm chart.
- IF the resource belong to a **community Helm Chart**, check if there is up-to-date chart supports the New Kubernetes Versin.
- IF the resource is added with adhoc-command , use `kubectl edit <resource> <name> -o yaml` or `kubectl patch` or `kubectl set`.. so on

# Upgrade Steps ----------------

## I. Upgrade Control Plane
```sh
# after TF module version update, run
terraform init
terraform apply
```
## II. Upgrade Worker Nodes

```sh
# evict workload
node=ip-x-y-z-x.region.compute.internal
kubectl drain ${node} --ignore-daemonsets --force --delete-local-data
# terminate the instance

```


# Post-upgrade Steps ----------------
>  [REFERENCE][5]

| Kubernetes version      | 1\.16    | 1\.15     | 1\.14    | 1\.13     |
|-------------------------|----------|-----------|----------|-----------|
| Amazon VPC CNI plug\-in | 1\.6\.1  | 1\.6\.1   | 1\.6\.1  | 1\.6\.1   |
| DNS \(CoreDNS\)         | 1\.6\.6  | 1\.6\.6   | 1\.6\.6  | 1\.6\.6   |
| KubeProxy               | 1\.16\.8 | 1\.15\.11 | 1\.14\.9 | 1\.13\.12 |

#  I. Kubernetes add-ons VPC CNI plugin

```sh
# check the current version
kubectl -n kube-system get daemonset aws-node -o=jsonpath='{$.spec.template.spec.containers[:1].image}'
# patch
kubectl apply -f \
  https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.6/config/v1.6/aws-k8s-cni.yaml

```


## II. Kubernetes add-ons - CoreDNS 

**1. coredns configmap update**

```sh
# Replace "proxy . /etc/resolv.conf" by "forward . /etc/resolv.conf"
kubectl -n kube-system edit configmap coredns
```

**2. coredns deployment patch**

```sh

# get current image
current_image=$(kubectl -n kube-system get deployment coredns -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
# get current image base
image_base=$(echo ${current_image}| sed 's#:.*##')
# patch
kubectl -n kube-system \
  set image deployment.apps/coredns \
    coredns=${image_base}:v1.6.6
```

## III. Kubernetes add-ons - kube-proxy 

**1. kube-proxy patch**

```sh
# get current image
current_image=$(kubectl -n kube-system get daemonset kube-proxy -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
# get current image base
image_base=$(echo ${current_image}| sed 's#:.*##')

# patch
kubectl -n kube-system \
  set image daemonset.apps/kube-proxy \
    kube-proxy=${image_base}:v1.16.8
```

## IV. Others

Any failed pre-upgrade must be done in the last steps.

**1. Prometheus**

- https://stackoverflow.com/a/58572044/747579
- https://stackoverflow.com/a/58558179/747579







[1]: https://github.com/terraform-aws-modules/terraform-aws-eks/releases/tag/v12.0.0
[2]: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-1.16
[3]: https://kubernetes.io/blog/2019/09/18/kubernetes-1-16-release-announcement/
[4]: https://kubernetes.io/blog/2019/07/18/api-deprecations-in-1-16/

[5]: https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html