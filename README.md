# Cluster Operations Pipeline

## Cluster Operations

The cluster operations are composed by 2 pipelines:

* **set-clusters-pipeline** reads the `vars/((foundation))/k8s-clusters.yml` file and creates a pipeline for each one of the clusters described in the file. The pipelines created by the Job set-clusters-pipeline are named with the name of the cluster.

* __<cluster_name> pipeline__: Contains all of the jobs responsible for managing a cluster lifecycle, including `create-cluster`, `set-cluster-runtime`, `upgrade-cluster`, etc.

See the cluster pipeline docs here: [cluster pipeline](/pipeline/cluster-operations/README.md)

## Base Operations

### Create Cluster

#### Check List

* Cluster Name and Tags from cluster requester
* Cluster template in k8s-cluster.yml
* New Cluster Pipeline
* Master Plane LB and CNAME
* RBAC setup
* Dynatrace Addon configure
* Upgrade cluster


#### Define TKGI Cluster

Define the cluster confing in the file /vars/((foundation))/k8s-cluster.yml

Example:

```yaml
- CLUSTER_NAME: cf-np-nexusops3
  PLAN: small
  EXTERNAL_HOSTNAME: <CLUSTER_NAME>.host.com
  TAGS: Access:internet
  K8S_PROFILE: "oidc-config"
  NETWORK_PROFILE: ""
  NUM_NODES: ""
```

Git commit and push the changes in k8s-clusters.yml

A pipeline with the same name as the cluster will be created in Concourse.

#### Run Create Cluster Job

If this is the first time working with this cluster you need to unpause thje cluster pipeline.

In Concourse, the new pipeline named after the cluster has a job called `create-cluster`

```If this is the first time working with this cluster you need to unpause the cluster pipeline first.```

Trigger a new build of the job called `create-cluster`

It will take about 15 min depending on your cluster size.

#### Test

Try tkgi login to the new cluster, get-credentials, get-kubeconfig with user Admin.

### Set Rbac

If there's any change on the RBAC roles or LDAP groups, run set-rbac Job:

In the Concourse cluster pipeline there's a `set-rbac` Job. Run this job to map the RBAC roles to LDAP groups.

The RBACs to be applied are in vars/((foundation))/rbac

### Scale Cluster

To change the number of worker nodes in your cluster:

1. go to /vars/((foundation))/k8s-cluster.yml

2. identify the cluster config in the file

3. change the value for `NUM_NODES`

4. git commit and push

    This will trigger the set-cluster-pipeline job, which will update the cluster pipeline.

5. After the cluster pipeline is updates, run the job `set-cluster-num-workers`

### Upgrade Cluster

After a TKGi upgrade or a change of config in OpsManager, to propagate the changes to the clusters you need to `tkgi upgrade` the cluster.  
This will recreate all of the cluster nodes appliyng the new version or config from TKGi.

1. Go to Concourse web UI.

2. Find your cluster pipeline in you environment.

3. Run the `upgrade-cluster` Job in the pipeline.

### Delete Cluster

1. Run delete-cluster pipeline Job.

2. After it finished, run a `fly -t <target> destroy-pipeline -p pipeline-name`.
