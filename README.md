# Vault Explorer for Metrics via OSS Grafana/Prometheus

![img](img/vault_grafana_dashboard.png)

### Description
This is a fork of Nico Kabar's Vault Lab (https://github.com/nicolaka/vault-lab/) that has been stripped of the local deployment of a lab Vault Cluster, Vault Namespaces and other extraneous additions, to focus solely on providing metrics observability into an existing Vault deployment hosted anywhere. The purpose of this application is to provide Vault users with a quick and easy metrics tool to measure client counts, traces, and other log information in a digestible format.  



### Requirements:

- Vault Enterprise/Dedicated License 
- [Docker for Mac/Windows](https://docs.docker.com/desktop/install/mac-install/) with Kubernetes turned on (only tested this on Docker for Mac)
- Terraform CLI
- Vault CLI
- `kubectl` CLI
- [httpie](https://httpie.io/) which is easier/cooler version of `curl`. You can use just curl but need to convert the commands :)


### Deployment Steps

1. Clone this repo into your local environment that has Docker for Mac/Windows running. 

2. Ensure that `kubectl` is correctly configured

```
 $ kubectl get nodes
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   63d   v1.28.2

 $ kubectl cluster-info     
Kubernetes control plane is running at https://kubernetes.docker.internal:6443
CoreDNS is running at https://kubernetes.docker.internal:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

3. Export your Vault Server's web address+port, API Key (read only from root namespace, and namespace):
```
$ export VAULT_ADDR="http://yourvaultaddress:0000" 
$ export VAULT_TOKEN="API Vault Token"
$ export VAULT_NAMESPACE="root"
```

4. Ensure that your Docker Desktop Kubernetes configs are located in `~/.kube/config` or update the kubernetes provider config in the `providers.tf` file to reflect the actual path for your kubernetes config if it's not `~/.kube/config`. 

> Note: If you are running Terraform on natively on Mac/Windows(locally) then you need to update the Vault provider configs under `provider.tf` and choose the right `address` config (details in the comments in provider.tf) 


5. Initialize Terraform and run Terraform Plan/Apply


```
$ terraform init                

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/vault from the dependency lock file
- Reusing previous version of hashicorp/helm from the dependency lock file
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Using previously-installed hashicorp/vault v3.24.0
- Using previously-installed hashicorp/helm v2.12.1
- Using previously-installed hashicorp/kubernetes v2.25.2

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.


$ terraform apply --auto-approve
...

Apply complete! Resources: 43 added, 0 changed, 0 destroyed.

Outputs:

alice_entity_lookup_id = "5ebdf273-3465-a6a3-0f39-9b1965e8cfcd"
alice_pre_created_entity_id = "8cd5d3de-e251-33b7-eed7-943fd916c2fe"
bob_entity_lookup_id = "2129b0a3-32fa-da3f-06c6-804d00bda5ba"
bob_pre_created_entity_id = "2129b0a3-32fa-da3f-06c6-804d00bda5ba"
dave_entity_lookup_id = "fbd55dbe-bfdb-5b49-c8b9-14c6667b37a5"

```

6. It will take a few minutes for the deloyment to finish, once it does you can validate that it deployed successfully

```
$ kubeclt get pod -n vault
NAME                                                            READY   STATUS      RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0          2/2     Running     0          3m3s
benchmark-jhf5q                                                 0/1     Completed   0          2m28s
ldap-6b49f5c885-9dc4w                                           1/1     Running     0          3m29s
prometheus-grafana-9c98f646b-vndgg                              3/3     Running     0          3m4s
prometheus-kube-prometheus-operator-7664bd5b4b-8nbwb            1/1     Running     0          3m4s
prometheus-kube-state-metrics-6db866c85b-bfd8t                  1/1     Running     0          3m4s
prometheus-prometheus-kube-prometheus-prometheus-0              2/2     Running     0          3m3s
prometheus-prometheus-node-exporter-57kzx                       1/1     Running     0          3m4s
vault-0                                                         1/1     Running     0          3m25s
vault-agent-injector-559b9646cb-flbq7                           1/1     Running     0          3m26s
vso-vault-secrets-operator-controller-manager-9df69fbd5-phw9j   2/2     Running     0          3m10s


$  kubectl get ns    
NAME              STATUS   AGE
blue              Active   2m21s
default           Active   63d
kube-node-lease   Active   63d
kube-public       Active   63d
kube-system       Active   63d
red               Active   2m21s
vault             Active   2m21s

```

7. Once you deploy, these are the exposed services that you can acccess via your web browser:

| Name | Description | IP/Port | Credentials
| - | - | - | - |
| Prometheus | Prometheus Server | `http://localhost:30090` | None |
| Grafana | Grafana Server | `http://localhost:30002` | `admin/vault` |





### Vault API Identity + Clients Reference
```
# Returns details on the total number of entities 
$ http $VAULT_ADDR/v1/sys/internal/counters/entities "X-Vault-Token: $VAULT_TOKEN"

 # Returns details on the total number of tokens
$ http $VAULT_ADDR/v1/sys/internal/counters/tokens "X-Vault-Token: $VAULT_TOKEN"

 
# Returns total client count breakdown by auth method by namespace and new clients by month
$ http $VAULT_ADDR/v1/sys/internal/counters/activity "X-Vault-Token: $VAULT_TOKEN" 

# Returns a list of unique clients that had activity within the provided start/end time 
$ http $VAULT_ADDR/v1/sys/internal/counters/activity/export "X-Vault-Token: $VAULT_TOKEN" 

  
# Returns client activity for the current month 
$ http $VAULT_ADDR/v1/sys/internal/counters/activity/monthly "X-Vault-Token: $VAULT_TOKEN" 

```

### Prometheus + Grafana Dashboards

We deployed a full Prometheus + Grafana Stack and loaded up a sample Grafana dashboard to monitor Vault and VSO. You can access Grafana using `http://localhost:30002` and login with username `admin` and password `vault`. Then go to **Dashboards > HashiCorp Vault** 

![img](img/vault_grafana_dashboard.png)


## Grafana Dashboard Summary
| Name | Description | Data Source (API or Telemetry) | Type | Scope  | Implementation Status |
| - | - | - | - | -| -| 
| Current Total Entity Count | The total number of identity entities currently stored in Vault | `vault.identity.num_entities` | `Gauge` | Global |  ✅ | 
| Current Total Entity Count Time-Series Graph | The total number of identity entities currently stored in Vault | `vault.identity.num_entities` | `Time-Series Graph` | Global |  ✅ | 
| Entity List | A list of identity entities currently stored in Vault | `/v1/identity/entity/name?list=true` | `Table` | Global |  ✅ | 
| Entity Alias Count by Auth Method | The number of identity entity aliases by auth method | `vault_identity_entity_alias_count` | `Chart` | Global |  ✅ | 
| Entity Alias Count by Namespace | The number of identity entity aliases by namespace | `vault_identity_entity_alias_count` | `Chart` | Global | ❌ | 
| Vault Clients Summary (Current Month) | A summary of distinct entities that created a token during the current month | `/internal/counters/activity/monthly` | `Table` | Global |  ✅ | 
| Active Clients Count (Current Month) | The number of distinct entities (per namespace) that created a token during the current month | `vault.identity.entity.active.partial_month` |`Gauge`| Global |  ✅ |
| Active Clients Count (Current Month) Time-Series Graph| The number of distinct entities (per namespace) that created a token during the current month | `vault.identity.entity.active.partial_month` | `Time-Series Graph` | Global |  ✅ |
| Monthly Client Clount Time-Series Graph| The number of distinct entities (per namespace) that created a token during the past month | `vault.identity.entity.active.monthly` | `Time-Series Graph` | Global |  ✅ |  
| Active Client Details| Detailed summary of clients | `/v1/sys/internal/counters/activity/export` | `Table` | Global |  ✅ |  
| Entity Alias Details| Detailed summary of entity aliases | `/v1/identity/alias/id?list=true` | `Table` | Global |  ✅ |  




### Teardown

```
$ kubectl delete -f app-a.yml -n blue
$ kubectl delete -f app-b.yml -n red
$ terraform destroy --auto-approve
```

For brute-force style teardown, you can issue `kubectl delete ns blue red vault`, and in case you have a namespace stuck in the `Terminating` state you can issue this command to clear any k8s finalizers 

```
NS=`kubectl get ns |grep Terminating | awk 'NR==1 {print $1}'` && kubectl get namespace "$NS" -o json | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"   | kubectl replace --raw /api/v1/namespaces/$NS/finalize -f - 

```





