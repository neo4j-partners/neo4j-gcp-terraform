# Neo4j Deployment using Terraform (GCP)
This repo provides [Terraform](https://www.terraform.io/) templates to support deployment of Neo4j Graph Data Platform in some of the major Cloud Service Providers.

## **Prerequisites**

### Terraform
A working Terraform setup in your local machine or host which is going to be used to perform the Cloud deployments. You can get the latest version of Terraform [**here**](https://www.terraform.io/downloads.html). It is highly recommended to go through introduction tutorials [**here**](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?in=terraform/gcp-get-started) for GCP.

### Environment Setup
You will need a GCP account.

We also need to install glcoud.  Instructions for installing the Google Cloud SDK that includes gcloud are [here](https://cloud.google.com/sdk/).

Now, you'll need a copy of this repo.  To make a local copy, run the commands:

    git clone https://github.com/neo4j-partners/neo4j-gcp-terraform
    cd neo4j-gcp-terraform
    
To set up your Google environment and log into Google, run the command:

    gcloud init
    gcloud application-default login

## **Folder structure**
All the templates in this repo follow a similar folder structure.

```
./
./main.tf              <-- Terraform file that contains the Primary node(s) infrastruture deployment instructions (Infrastruture and Neo4j configs are parameterised and will be passed through the `variable.tf` file)
./main-gds.tf          <-- Terraform file that contains the Secondary/GDS node(s) infrastruture deployment instructions (Infrastruture and Neo4j configs are parameterised and will be passed through the `variable.tf` file)
./loadbalancer.tf      <-- Terraform file that contains the load balancing infrastruture
./loadbalancer-gds.tf  <-- Terraform file that contains the load balancing infrastruture
./network.tf           <-- Terraform file that contains the network infrastruture
./provider.tf          <-- Terraform file that contains cloud provider and project information
./variables.tf         <-- Terraform file that contains all the input variables that is required by the `main.tf` file to deploy the infrastruture and Neo4j
./terraform.tfvars     <-- Terraform variables files that contains values to pass to the script. Override default values defined in variables.tf. See terraform.tfvars_sample
./keys                 <-- Folder contains Cloud Service Provider Service Account Keys (This is going to vary from vendor to vendor)
./scripts              <-- Folder contains platform/services setup script template that will be executed after the infrastructure is provisioned
./out                  <-- Folder contains rendered setup script that is executed at startup inside the provsioned VM
```

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
   7. DNS Administrator (Optional - If you plan to assign a DNS to the load balancer)
   8. Service Account User
   9. Storage Admin
4. For the Service Account, go to 'Manage Keys' and 'Add Key'. Save the `keys.json` file and place it inside the `./keys/` folder
5. Create `terraform.tfvars` and fill your project details. See `terraform.tfvars_sample` for example. Check the documentation for required variables. Some of them are having default values. 

   Example:

   ```
   project = <Project Name>
   region = <Project Region>
   zone = <Project Zone>
   # Use the email for service_account found in IAM > Service account, e.g. sa@email.com
   service_account = <Service-Account>
   credentials = keys/keys.json
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