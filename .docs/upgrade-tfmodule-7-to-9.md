# Overview : 

Summary of required steps to UPGRADE:

- From EKS Terraform Module 7.0.0 (k8s 1.14)
- To EKS Terrafomr Module 9.0.0 (k8s 1.14)


# Steps

## 1. Change the EKS Module Version in main.tf (7.0.0 -> 9.0.0)

## 2. Terraform container requires aws-iam-authenticator

## 3. kubernetes provider managed by Terraform 

**temporarily Static config**

## 4. Temporarily Remove aws-auth Config Map

## 5. Trigger the UPGRADE `terraform apply` 

## 6. kubernetes provider managed by Terraform 

**Permanently Dynamic config**