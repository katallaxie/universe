# Universe - Remote iPad Setup

> [iPadOS](https://www.apple.com/ipados/ipados-preview/) is recommended for best support in Safari
> Create a short cut on your home screen for full screen support

## Features:

* Provisioning of worker node on [Scaleway](https://www.scaleway.com) 
* [VS Code Remote Server](https://github.com/cdr/code-server) configured with [Let's Encrypt](https://letsencrypt.org/)
* Prepared for @golang

## Remote Worker

A worker node is created and provisioned with [bootstrap.sh](/bootstrap.sh). You can access this node using you provided `private_key`.

### Setup

```
# init the state
terraform init

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