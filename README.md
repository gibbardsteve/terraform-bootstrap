# terraform-bootstrap

Configure the terraform backend for future IaC config. Use this repository to set up a terraform backend in AWS using S3 and Dynamo DB.

## Prerequisites

Clone this repo locally, ensure terraform is installed (brew install terraform)

### Usage

**One: Create a user for terraform**
Create a terraform user with privileges to:

- create S3
- create DynamoDb

**Two: Add access keys to user**
Create a access key credentials for the terraform user in the IAM console under Security Credentials.

**Three: Set up the cli for AWS authentication**
Use the aws cli to use the access keys associated with the terraform user

```bash
aws configure
```

If you have multiple aws credentials to manage consider using the ~/.aws/credentials file and profiles.

```bash
[default] #This is the default profile
aws_access_key_id = abcdef
aws_secret_access_key = ghijkl

[app2_account] #This is the profile name
aws_access_key_id = vwxyz
aws_secret_access_key = cdefg
```

A specific profile can be set by using:

```bash
export AWS_PROFILE=app2_account
```

**Four: Create the S3 and Dynamo DB Tables**
In the main.tf code ensure that the block mentioning "backend" is _commented_ out, this will be uncommented once the resources are created.

**Update** the code to populate values for the placeholders:

```text
<BUCKET-NAME> - this is the name of the S3 bucket that will be created. example: <aws-account>-terraform-state
<CHOOSE-UNIQUE-PATH-FOR-BOOTSRAP-STATE> - this is a unique path to the state file for the bootstrap resources. example: /global/s3/terraform.state
<DYNAMO-DB-TABLE-NAME> - this is the name for the Dynamo DB table that ensures updates to state files are only allowed one at a time. example: terraform-state-lock
```

Change to the terraform directory and initialise terraform for local state

```bash
cd terraform
terraform init
```

Validate the terraform

```bash
terraform validate
```

Check the resources that will be created. 

```bash
terraform plan
```

If everything looks good apply the changes to create the resources.

```bash
terraform apply
```

**Five: Check the resources were created successfully**

In the AWS console verify that the S3 and Dynamo DB tables were created.

**Six: Swap the terraform state from local to use the AWS backend**

In main.tf **uncomment** the backend block, ensure the placeholders match the names used for the S3 and Dynamo DB resources.

Push the local state to the backend:

```bash
terraform init
```

**The terraform backend should now be setup to record state in AWS S3**

### Updating subsequent terraform

This repo creates the basic bootstrap to allow state to be recorded in an AWS account. Once this has been done the backend code block should be copied to the terraform you are using to configure your main solution.

Ensure further terraform config has the following:

```terraform
terraform {
   backend "s3" {
     bucket         = "<BUCKET-NAME>"
     key            = "<CHOOSE-UNIQUE-PATH-FOR-SOLUTION>/terraform.tfstate"
     region         = "eu-west-2"
     dynamodb_table = "<DYNAMO-DB-TABLE-NAME>"
   }
}
```

The placeholders above should match the values used for the bootstrap resources **Apart from the key**, which should be unique to the terraform you are writing for your solution.