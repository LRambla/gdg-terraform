# Code scratchpad / copy-and-paste
 [TERRAFORM DOC](bit.ly/48kEjlK)
 
### IMPORTANT TO UNDERSTAND:
When we execute Terraform (terraform apply), it "joins" all *.tf files in one. Splitting terraform code in different files is just a way to order the code in a more legible way. 


## Using the CLI
```
    # the alias saves you a few keystrokes
    $ alias tf=terraform
    $ tf init
    # what did it do? spot local changes
    $ tf plan
    $ tf apply
    $ tf output
    $ tf plan
    # is this what you expected?
    # replace content attribute
    $ tf plan
    # what changed from the previous plan?
    $ tf apply
    $ tf destroy
```

## Google Provider and credentials
[providers.tf](providers.tf)


### default application credentials
```
    $ gcloud auth login --update-adc
    # service account key
    # (Not Recommended)
    $ export GOOGLE_CREDENTIALS=~/my-key.json
```

## Resource Dependency

```
    resource "random_pet" "random" {
    length = 2
    separator = "-"
    }

    resource "google_storage_bucket" "bucket" {
    project       = "tf-playground"
    name          = "${random_pet.random.id}-tfws"
    location      = "US"
    storage_class = "MULTI_REGIONAL"
    labels        = {
        usage = "terraform workshop"
    }
    # explicit dependency, not useful here
    depends_on    = [random_pet.random]
    }
```


## Variables
[variables.tf](variables.tf)

### Setting variables at runtime
```
    # key/value file picked up automatically
    # by the CLI based on naming:
    # terraform.tfvars or *.auto.tfvars
    project_id = "my-project"
    names = ["first", "second"]
    labels = {one = 1, two = 2}
```

### environment variables
```
    $ TF_VAR_project_id="my-project" \
    tf apply
    # CLI options
    $ tf apply -var project_id="my-project"
    # non-auto .tfvars file
    $ tf apply -var-file my-vars.tfvars
    # if using terraform.tfvars or *.auto.tfvars
    $ tf apply

```



## Remote state and backends
[backend.tf](backend.tf)

We need to configure a gcs bucket to upload tfstate file. 

```
# migrate state
$ tf init
# remove local state file
$ rm terraform.tfstate*
# pull remote state
$ tf state pull

```

## Add and optional prefix to the name
```
    variable "prefix" {
    description = "Optional name prefix."
    # set the appropriate type and default
    }
    resource "random_pet" "random" {
    count = var.prefix == null ? 1 : 0
    }
```

### default is to use a random prefix
```
    $ tf apply
    name = mypet-tf-workshop
    # if the prefix variable is set it's used
    $ tf apply -var prefix=foo
    name = foo-tf-workshop
```


## Local values
```
locals {
  prefix = (
    var.prefix != null
    ? var.prefix
    : random_pet.random[0].id
  )
}

resource "myprovider_myresource" "foo" {
  name = "${local.prefix}-${var.name}"
}
```

## Triggering count recreation
```
$ tf apply -var names='["one", "two"]'
names = [
  "ladybird-one",
  "ladybird-two",
]

$ tf apply -var names='["two", "one"]'
# wooops, our buckets have been recreated
names = [
  "ladybird-two",
  "ladybird-one",
]
```

## Playing with for transformations
```
    # [for i in range(0, 5) : {a = f(i), b = i}]

    $ tf console

    > range(0, 5)
    [0, 1, 2, 3, 4]

    > cidrsubnet("10.0.0.0/8", 16, 0)
    10.0.0.0/24

    > cidrhost(cidrsubnet("10.0.0.0/8", 16, 0), 1)
    10.0.0.1
```

## Improve multiple buckets
```
    resource "google_storage_bucket" "bucket" {
        for_each           = toset(var.names)
        # use each.value to set name attribute
        name               = ?
    }
    output "names" {
        description = "Bucket names."
        value       = [
            for bucket in google_storage_bucket.bucket :
            bucket.name
        ]
    }
```

```
    $ tf destroy
    $ tf apply -var prefix=""
    # no error should be raised
```

## Modulo de Terraform de Compute Engine 

DOC: 
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance

Tipos de máquina de la familia E2:
https://cloud.google.com/compute/docs/general-purpose-machines#e2_machine_types

```
resource "google_compute_network" "my_vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  ip_cidr_range = "192.168.0.0/24"
  region        = "us-east4"
  network       = google_compute_network.my_vpc.id
}


resource "google_compute_instance" "my_www_vms" {
  name         = "my-vm"
  machine_type = "e2-medium"
  zone         = "us-east4-a"


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = google_compute_network.my_vpc.id
    subnetwork = google_compute_subnetwork.my_subnet.id
  }
}

```


