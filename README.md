# Neo4j Deployment using Terraform (GCP)

This repo provides [Terraform](https://www.terraform.io/) templates to support deployment of Neo4j Graph Data Platform in some of the major Cloud Service Providers.

## **Prerequisites**

### Terraform

A working Terraform setup in your local machine or host which is going to be used to perform the Cloud deployments. You can get the latest version of Terraform [**here**](https://www.terraform.io/downloads.html). I highly go through introduction tutorials [**here**](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?in=terraform/gcp-get-started) for GCP.

### Environment Setup
You will need a GCP account.

We also need to install glcoud.  Instructions for installing the Google Cloud SDK that includes gcloud are [here](https://cloud.google.com/sdk/).

To set up your Google environment, run the command:

    gcloud init

Now, you'll need a copy of this repo.  To make a local copy, run the commands:

    git clone https://github.com/neo4j-field/neo4j-terraform-deployment.git
    cd neo4j-terraform-deployment/Neo4jCluster
    
## **Folder structure**

All the templates in this repo follow a similar folder structure.

```
./
./main.tf           <-- Terraform file that contains the infrastruture deployment instructions (Infrastruture and Neo4j configs are parameterised and will be passed through the `variable.tf` file)
./provider.tf       <-- Terraform file that contains cloud provider and project information
./variables.tf      <-- Terraform file that contains all the input variables that is required by the `main.tf` file to deploy the infrastruture and Neo4j
./terraform.tfvars  <-- Terraform variables files that contains values to pass to the script. Overrode default values defined in variables.tf. See terraform.tfvars_sample
./keys              <-- Folder contains Cloud Service Provider Service Account Keys (This is going to vary from vendor to vendor)
./scripts           <-- Folder contains platform/services setup script template that will be executed after the infrastructure is provisioned
./out               <-- Folder contains rendered setup script that is executed at startup inside the provsioned VM
```

<br>

<br>

### Google Cloud Platform (GCP)

You will need access to a GCP user account with privileges to create Service Account and assign Roles to support deployment using Terraform.

<br>

## **Setup**

1. Setup Terraform
2. Clone this repo
3. Create a Service Account and assign the following roles:
   1. Compute Admin
   2. Compute Image User
   3. Compute Network Admin
   4. Compute Security Admin
   5. Dataproc Administrator (Optional - If you're going to use DataProc)
   6. Dataproc Worker (Optional - If you're going to use DataProc)
   7. DNS Administrator (Optional - If you're using the Causal Cluster deployment template)
   8. Service Account User
   9. Storage Admin
4. Download the `keys.json` file and place it inside the `./keys/` folder
5. Create `terraform.tfvars` and fill your project details. See `terraform.tfvars_sample` for example. Check the documentation for required variables. Some of them are having default values. 

   Example:

   ```
   project = <Project Name>
   region = <Project Region>
   zone = <Project Zone>
   # Use the email for service_account found in IAM > Service account, e.g. sa@email.com
   service_account = <Service-Account>
   ```

<br>

## **Usage**

### Deployment steps

1. Initialise the Terraform template

```
terraform init
```

2. Plan the deployment, this prints out the infrastructure to be deployed based on the template you have chosen

```
terraform plan
```

3. Deploy!! (By default this is an interactive step, when the time is right be ready to say **`'yes'`**)

```
terraform apply
```

4. When it's time to decommission (destroy) the deployment. (By default this is also an interactive step, when the time is right be ready to say **`'yes'`**)

```
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
#### Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider_google) | 3.85.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider_google-beta) | 4.60.1 |
| <a name="provider_local"></a> [local](#provider_local) | 2.4.0 |

#### Modules

No modules.

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_bloomLicenseKey"></a> [bloomLicenseKey](#input_bloomLicenseKey) | License key for the Neo4j Bloom plugin | `string` |
| <a name="input_graphDataScienceLicenseKey"></a> [graphDataScienceLicenseKey](#input_graphDataScienceLicenseKey) | GDS license to be used by this Terraform deployment | `string` |
| <a name="input_project"></a> [project](#input_project) | The project id where the VPC being provioned | `string` |
| <a name="input_service_account"></a> [service_account](#input_service_account) | Service account used by this Terraform deployment | `string` |
| <a name="input_adminPassword"></a> [adminPassword](#input_adminPassword) | Neo4j admin password | `string` |
| <a name="input_allow_stopping_for_update"></a> [allow_stopping_for_update](#input_allow_stopping_for_update) | n/a | `string` |
| <a name="input_auto_create_subnetworks"></a> [auto_create_subnetworks](#input_auto_create_subnetworks) | If true, Terraform will automatically create subnetworks for the VPC | `string` |
| <a name="input_credentials"></a> [credentials](#input_credentials) | GCP Credentials | `string` |
| <a name="input_enable_health_check"></a> [enable_health_check](#input_enable_health_check) | Flag to indicate if health check is enabled. If set to true, a firewall rule allowing health check probes is also created. | `bool` |
| <a name="input_env"></a> [env](#input_env) | Environment label used by this Terraform deployment | `string` |
| <a name="input_firewall_target_tags"></a> [firewall_target_tags](#input_firewall_target_tags) | Firewall rule tags used by this Terraform deployment | `list(string)` |
| <a name="input_installBloom"></a> [installBloom](#input_installBloom) | Install Neo4j Bloom (Yes/No) | `string` |
| <a name="input_installGraphDataScience"></a> [installGraphDataScience](#input_installGraphDataScience) | Install Neo4j GDS (Yes/No) | `string` |
| <a name="input_labels_group"></a> [labels_group](#input_labels_group) | Group labels used by this Terraform deployment | `string` |
| <a name="input_machine_type"></a> [machine_type](#input_machine_type) | Machine type of the VM being provisioned by this Terraform deployment | `string` |
| <a name="input_neo4j_access_external_ports"></a> [neo4j_access_external_ports](#input_neo4j_access_external_ports) | External access firewall rule ports used by this Terraform deployment | `list(string)` |
| <a name="input_neo4j_access_internal_ports"></a> [neo4j_access_internal_ports](#input_neo4j_access_internal_ports) | Internal access firewall rule ports used by this Terraform deployment | `list(string)` |
| <a name="input_neo4j_disk_size"></a> [neo4j_disk_size](#input_neo4j_disk_size) | Size of the storage disk used by this Terraform deployment | `number` |
| <a name="input_neo4j_disk_type"></a> [neo4j_disk_type](#input_neo4j_disk_type) | Type of the storage disk used by this Terraform deployment (pd-ssd, pd-balanced, pd-standard) | `string` |
| <a name="input_neo4j_version"></a> [neo4j_version](#input_neo4j_version) | Neo4j version to be installed | `string` |
| <a name="input_nodeCount"></a> [nodeCount](#input_nodeCount) | Number of Neo4j nodes to be deployed | `number` |
| <a name="input_private_zone_dns"></a> [private_zone_dns](#input_private_zone_dns) | Private DNS setup for setting up Cluster resolver | `string` |
| <a name="input_recordset_name"></a> [recordset_name](#input_recordset_name) | Private DNS setup recordset name | `string` |
| <a name="input_region"></a> [region](#input_region) | Region where the VM is being provisioned | `string` |
| <a name="input_scheduling_automatic_restart"></a> [scheduling_automatic_restart](#input_scheduling_automatic_restart) | n/a | `string` |
| <a name="input_scheduling_preemptible"></a> [scheduling_preemptible](#input_scheduling_preemptible) | n/a | `string` |
| <a name="input_subnetwork_range"></a> [subnetwork_range](#input_subnetwork_range) | CIDR range of the subnetwork used by this Terraform deployment | `string` |
| <a name="input_vm_boot_disk_delete_on_termination"></a> [vm_boot_disk_delete_on_termination](#input_vm_boot_disk_delete_on_termination) | n/a | `string` |
| <a name="input_vm_name"></a> [vm_name](#input_vm_name) | Name of the VM being provisioned by this Terraform deployment | `string` |
| <a name="input_vm_os_image"></a> [vm_os_image](#input_vm_os_image) | OS image used by this Terraform deployment | `string` |
| <a name="input_vpc_name"></a> [vpc_name](#input_vpc_name) | Name of the VPC being used by this Terraform deployment | `string` |
| <a name="input_zone"></a> [zone](#input_zone) | Zone where the VM is being provisioned | `string` |
<!-- END_TF_DOCS -->