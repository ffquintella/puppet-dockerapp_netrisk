# dockerapp_netrisk

This is the dockerapp_netrisk module. Basically what it does is install and configures the netrisk application using docker images. 

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with dockerapp_netrisk](#setup)
    * [What dockerapp_netrisk affects](#what-dockerapp_netrisk-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with dockerapp_netrisk](#beginning-with-dockerapp_netrisk)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This is the easiest way to install and configure the netrisk application and also the default recommended one. 

## Setup


### Setup Requirements **OPTIONAL**

This module is dependent of the dockerapp base module.

### Beginning with dockerapp_netrisk

Just call the class and pass the parameters.


## Usage

Just call the class and pass the parameters. See `manifests/init.pp` for the
full list of parameters and their documentation.

### Application data and backups

The api, console and backgroundjobs containers each bind-mount their own
`appdata` directory at `/var/netrisk`, the path where the application keeps its
server state — the JWT signing token and the master key that encrypts stored
integration credentials (webhooks, Jira and Azure DevOps tokens, API keys, OIDC
client secrets, biometric templates). These directories are created mode `0700`
and owned by `$user`.

Because that state now survives container recreation, **backing up
`${base_app_home}/${service_name}` is what makes a host rebuild
non-destructive** — and that directory now contains key material, so treat the
backup accordingly. Without it, a rebuilt host mints a new master key and every
stored integration credential fails to decrypt.

### `secret_master_key`

By default the host generates and persists its own master key on the volume
above. Set `secret_master_key` to supply it from Hiera (eyaml) or a vault
instead. It must be the base64 encoding of 32 bytes:

```sh
openssl rand -base64 32
```

Anything else fails compilation, since a wrong-length key is only noticed once
the application refuses to decrypt the credentials it already stored.

Use it when the application data directory is not backed up, or when several
hosts must read the same credentials.

There is a trade-off. Passing the key as a container environment variable puts
it in `docker inspect` output and in the generated systemd unit, readable by
anyone who can reach the Docker socket. The database password already travels
this way (`FACTER_DBPASSWORD`), so this is not a new class of exposure — but it
is a real one, and the persisted volume avoids it entirely. Prefer the volume;
use `secret_master_key` when you need the key to be an input to the deployment
rather than host state.

## Limitations

See `metadata.json` for the supported operating systems.

## Development

This module is developed and tested with
[Regent](https://github.com/felipe-quintella/regent), a self-contained,
Rust-based PDK alternative with an embedded Ruby runner. PDK and a host Ruby /
Bundler toolchain are **not** required.

```sh
regent bootstrap   # one-time: install the gems Regent needs
regent fixtures    # install the modules declared in .fixtures.yml
regent validate    # parse manifests + metadata.json, lint
regent test        # run the rspec-puppet specs
regent build       # produce a Forge-ready tarball in pkg/
```

See [AGENTS.md](AGENTS.md) for the full contributor / agent workflow.

