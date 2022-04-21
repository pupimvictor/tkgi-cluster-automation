# Cluster Operations

## UAA

UAA is the User Authorization and Authentication service for TKGI clusters. It's responsible to translate AD users and groups into token the kube api can use to control access.

TKGI has 3 access level for Platform Admins and they need to be mapped to AD groups. This is done in `map_ad_to_uaa` Concourse during TKGI installation.

In order to have AD groups mapped in the kubeconfig token, UAA acts as OIDC server for Kubernetes. 
When a user logs in and tries to access resources in a given cluster, the groups in the token will be matched to RBACs in the cluster, and the proper access you be applied to the user.

## RBAC

In order to have access to a cluster, a user needs to be part of a group in AD which is listed in the RBAC templates for the cluster.

To add/remove access you should only be interacting with AD. RBAC changes such as new roles creation or different bindings should be properly scoped.

### Changes in AD not reflecting in the CLusters

Sometimes a change in AD doesn't immediatelly reflects in the cluster api. It's rare, but when it happens, a platform admin should login to UAA and delete the problematic user. the next time the user logs back in, it's access levels will be updated.

## Cluster Upgrades

Whenever there's a change in the TKGI deployment, being through OpsMan UI or a new TKGI version update, the clusters need to be upgraded.

To upgrade a cluster you must be sure it has enough resources to hold the workloads during the process. 

    That means, if your cluster is running above 70% capacity, you need to scale it up before running the Upgrade

This is necessary because during an upgrade Bosh will stop the cluster nodes one by one to release new software. During this process your workloads need to keep running despite one less node.
