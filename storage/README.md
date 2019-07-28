# Persistent Storage
We use an [AWS EBS][1] volume to retain the Let's Encrypt certificates between
reboots of the webserver instance. 

By tagging the EBS volume with the Name "lettuce", we make it discoverable by
the [parent module](../) as a terraform data object. In practice, this is a more
forgiving interface than working with terraform output / tfvars files.

This volume will be treated by the webserver as a [ZFS Storage Pool][2].
Admittedly, a single volume is not much of a pool, but creating it this way will
allow us to use `zpool import` to mount the volume which contains our certs.

```
  ┌───────────────────────────────────────┐                    ┌──────────────────────────┐
  │              EBS Volume               │                    │       EC2 Instance       │
  │                                       │                    │                          │
  │                                       │                    │                          │
  │                                       │                    │                          │
  │                                       │                    │                          │
  │ ┌───────────────────────────────────┐ │                    │    ┌────────────────┐    │
  │ │        "persistent" zpool         │ │                    │    │    illumos     │    │
  │ │                                   │ │                    │    │                │    │
  │ │                                   │ │                    │    │                │    │
  │ │                                   │ │                    │    │                │    │
  │ │                                   │ │                    │    │                │    │
  │ │ ┌───────────────────────────────┐ │ │◀──Attaches to──────│    │                │    │
  │ │ │      /persistent Volume       │ │ │                    │    │    ┌─────┐     │    │
  │ │ │               ┌─────────────┐ │ │◀┼──────Imports───────┼────│    │nginx│     │    │
  │ │ │    ┌─────────┐│fullchain.pem│ │ │ │                    │    │    │     │     │    │
  │ │ │    │chain.pem│└─────────────┘ │ │ │                    │    │    │     │     │    │
  │ │ │    └─────────┘ ┌────────┐     │◀┼─┼────Reads from──────┼────┼────│     │     │    │
  │ │ │ ┌───────────┐  │cert.pem│     │ │ │                    │    │    │     │     │    │
  │ │ │ │privkey.pem│  └────────┘     │ │ │                    │    │    │     │     │    │
  │ │ │ └───────────┘                 │ │ │                    │    │    │     │     │    │
  │ │ └───────────────────────────────┘ │ │                    │    │    └─────┘     │    │
  │ └───────────────────────────────────┘ │                    │    └────────────────┘    │
  └───────────────────────────────────────┘                    └──────────────────────────┘
```

[1]: https://aws.amazon.com/ebs/
[2]: https://illumos.org/man/zpool
