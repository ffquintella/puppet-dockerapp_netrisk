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

### FerroGate MIA

From image version 2.50.0 the `netrisk-api` and `netrisk-backgroundjobs` images
carry the FerroGate Machine Identity Agent (MIA) client, started by the
entrypoint, so NetRisk can consume data protected by FerroGate. The console and
website images do not have it, and this module never gives them any MIA volume
or variable. Configure it with `mia_mode`:

| `mia_mode` | Effect |
| --- | --- |
| `off` (default) | Nothing changes. Installations that do not set `mia_*` keep the exact same containers. |
| `embedded` | An agent runs inside the container with its own identity. Needs `mia_cmis_endpoint`, `mia_cmis_srv` or a `mia.toml`. |
| `host` | The container uses the MIA of the Docker host through its socket and identifies **as the host**. No agent runs in the container. |
| `auto` | The image chooses at start (host if the socket is mounted, else embedded if there is a CMIS endpoint, else off). The module only mounts the identity, not the host socket, so use `host` explicitly to reach the host MIA. |

Anything but `off` requires `version` >= 2.50.0 (or `latest`) and is rejected at
compile time otherwise, as are: embedded/auto with no endpoint, srv or
`mia.toml`; `host` with an empty `mia_host_socket_dir`; `mia_state_mode:
directory` without `mia_state_dir`; and `mia_config_source` together with
`mia_config_content`. Other `FERROGATE_*` variables go in `mia_env`
(`FERROGATE_ALLOWLIST_FETCH`, ...); keys that have a dedicated parameter are
refused there.

Embedded, identity in a named volume (the default):

```yaml
dockerapp_netrisk::version: '2.50.0'
dockerapp_netrisk::mia_mode: 'embedded'
dockerapp_netrisk::mia_required: true
dockerapp_netrisk::mia_cmis_endpoint: 'https://cmis.example.com:8443'
dockerapp_netrisk::mia_cmis_spki_pin: 'sha256/AbCd...='
dockerapp_netrisk::mia_env:
  FERROGATE_ALLOWLIST_FETCH: 'https://cmis.example.com:8443/allowlist'
# optional: a mia.toml from the node, mounted at /etc/ferrogate/mia.toml:ro
# dockerapp_netrisk::mia_config_source: '/srv/secrets/mia.toml'
```

Host MIA through its socket:

```yaml
dockerapp_netrisk::version: '2.50.0'
dockerapp_netrisk::mia_mode: 'host'
dockerapp_netrisk::mia_required: true
dockerapp_netrisk::mia_host_socket_dir: '/run/ferrogate'   # default
```

**The machine identity must persist.** In embedded mode `/var/lib/ferrogate`
holds the host key and SVID seed. The CMIS pins that key: if it is lost, the
host is rejected until a CMIS operator clears the binding. The image
deliberately has no `VOLUME` there and its entrypoint refuses to start the
embedded agent without an explicit mount, so the module always mounts it: a
named volume `<mia_state_volume>-api` / `-backgroundjobs` (default base
`<service_name>-mia`), or, with `mia_state_mode: directory`, the host
directories `<mia_state_dir>/api` and `/backgroundjobs` (mode `0700`; the
entrypoint chowns them to the agent account, so the owner is not managed). Each
container has its own identity. Include these in your backups and do not
`docker volume rm` them.

**In host mode the host allowlist must admit the application by the binary's
hash.** Entries restricted by path never match, because the container is
outside the mount namespace of the host MIA. The module mounts the
*directory* `mia_host_socket_dir` at `/run/ferrogate-host:ro`, not the socket
file, because the host MIA recreates the socket when it restarts.

Environment variables (including `mia_env`) are visible in `docker inspect`,
exactly like `FACTER_DBPASSWORD`. The SPKI pin is not a secret, but keep real
FerroGate credentials out of them; supply them in `mia.toml` instead, whose
`mia_config_source` file can be `0600` on the node. The `mia.toml` is mounted
as a single file, so after Puppet rewrites it the containers must be restarted
to see the new content.

**Not verified end to end.** The image build, attestation against a real CMIS
and the host socket path were not tested against the images. The specs cover
the catalog this module generates, not the behaviour of the agent.

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

