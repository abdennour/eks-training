

## 1. First of all, create an AWS user with high privileges

https://console.aws.amazon.com/console/home

## 2. Then, Install AWS CLI locally & Configure this user locally with AWS CLI

Check [docker-compose.yaml](docker-compose.yaml)

```sh
docker-compose run --rm aws configure --profile terraform-operator
```

## 3. Configure Terraform to use the AWS user with the AWS provider

Check [docker-compose.yaml](docker-compose.yaml)


## 4. Run Terraform Example to validate the authentication & authorization to AWS

Check [main.tf](main.tf)

then : 

```sh
docker-compose run --rm terraform init
docker-compose run --rm terraform apply
```
