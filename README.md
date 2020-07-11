
# Overview
Infrastructure-as-Code for spinning up EKS and deploying Helm charts via Terraform. Based on https://github.com/abdennour/eks-training, which is the material for [this Udemy course](https://www.udemy.com/course/aws-eks-kubernetes)

This repository is intended as a proving ground for managing services cleanly ahead of bundling the terraform into a brokerpak for the [cloud-service-broker](https://github.com/pivotal/cloud-service-broker).

# Requirements

Docker Compose is the only command-line client needed, and you can install it in
the stock way. All other clients (aws, kubectl, helm, terraform) are run via
`docker-compose run --rm <clientname>`.

# Setup

Copy the `.env.secrets-template` file to `.env.secrets`, then customize the values inside
   ```bash
   cp .env.secrets-template .env.secrets
   <editorname> .env.secrets
   ```

Environment configuration is keyed off the current Terraform workspace name.
Terraform will maintain a separate `.tfstate` file for each workspace.

The implicit Terraform workspace `default` corresponds to a production
environment. For each additional environment, you'll need a
terraform workspace with the corresponding name. The repository currently
contains configuration for a `staging` environment, so create that workspace:
```bash
docker-compose run --rm terraform workspace new staging
```
You can run `docker-compose run --rm terraform workspace select default` to
switch back to the default (production) configuration later.

There is a wrapper script, `run-docker-compose.sh`, that invokes the given
client and args while paying attention to which environment you're in, eg 
`./run-docker-compose terraform plan`. (You may want to 
`alias dcr='./run-docker-compose.sh'` to reduce the amount of typing
needed to operate this way, eg `dcr terraform plan`.)

Initialize the Terraform modules

```bash
./run-docker-compose.sh terraform init
```

Create an IAM user that you want to be used by Terraform: 
1. Click `Services > IAM > Users > Add user`.
1. Supply a name (eg `terraform-operator`) and click `Programmatic Access` for
   the Access Type. 
1. Click `Attach existing policies directly` and select the policy
   `AdministratorAccess` (or a more constrained policy as appropriate).
1. Skip the tags and create the user. 
1. Note the `Access key ID` and `Secret access key`.

Authenticate with AWS:
1. Run `./run-docker-compose.sh aws configure --profile terraform-operator`.
1. Supply the `Access key ID` and `Secret access key` from above.
1. Supply your desired region (and edit `locals.tf` if it's not `us-east-1`).
1. Leave the output format as-is.

Run Terraform apply:
```bash
./run-docker-compose.sh terraform apply
```

# Teardown

Run Terraform destory
```bash
./run-docker-compose.sh terraform destroy
```



