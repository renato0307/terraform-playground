# terraform-playground
Playground for Terraform learning

## folder structure

| Name | Description |
| ---- | ----------- | 
|infra|Terraform resources|
|infra/modules|Reusable Terraform modules|
|infra/tf_event_bus|Terraform project to create the internal event bus|
|infra/tf_lambdas|Terraform project to create the sample lambda function|
|infra/tf_setup|Terraform project to setup Terraform (create assets for the backend)|
|sample_lambda|Code for a sample lambda function|

## terraform commands

```
terraform init --backend-config=backend.tfvars
terraform init
terraform apply
```

