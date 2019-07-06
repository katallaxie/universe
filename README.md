# Universe - Remote iPad Setup

## Remote Worker

### Setup

```
# init the state
terraform init

# conduct plan
terraform plan

# apply
terraform apply
```

> you can destroy everything with `terraform destroy`

### Notes

* You should add your ssh key to the `ssh-agent`
* You need to configure the Scaleway API access 

```
export SCALEWAY_ORGANIZATION=${YOUR ACCESS KEY}
export SCALEWAY_TOKEN=${YOU API TOKEN}
```

* `region` is set in `main.vars.tf` 

# License
[MIT](/LICENSE)