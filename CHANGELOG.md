# Changelog

All notable changes to this project will be documented in this file.

## Release 1.5.0

**Features**
FerroGate MIA (Machine Identity Agent) support for the `api` and
`backgroundjobs` containers, which carry the client from image version 2.50.0
(console and website never get it). New parameters: `mia_mode` (`off` default,
`auto`, `embedded`, `host`), `mia_required`, `mia_cmis_endpoint`,
`mia_cmis_srv`, `mia_cmis_spki_pin`, `mia_allowlist_key`, `mia_env`,
`mia_config_source` / `mia_config_content`, `mia_state_mode`,
`mia_state_volume`, `mia_state_dir` and `mia_host_socket_dir`. Embedded and auto
always mount the machine identity at `/var/lib/ferrogate` (named volume or host
directory); host mode mounts the socket directory at `/run/ferrogate-host:ro`.
Invalid combinations and `version` < 2.50.0 fail at compile time. With the
default `mia_mode: off` the catalog is unchanged. See the README.

## Release 1.4.0

**Breaking change**
`db_password`, `api_ssl_cert_pwd`, `website_ssl_cert_pwd`, `sp_certificate_pwd`
and `secret_master_key` are now `Sensitive` (`Sensitive[String]`, and
`Optional[Sensitive[String[1]]]` for `secret_master_key`), so they are redacted
in logs and reports. Plain strings are no longer accepted: wrap the values in
Hiera with `lookup_options` / `convert_to: Sensitive`, or pass `Sensitive(...)`.

## Release 1.3.0

**Features**
New optional `api_ssl_cert_base64`, `website_ssl_cert_base64` and
`sp_certificate_base64` parameters. When set, the PFX is decoded from the
base64 value (e.g. straight from Hiera) and written to the certs directory, so
the certificate no longer has to be staged on the node beforehand. The
`*_cert_file` parameters are still used when no base64 value is given.

## Release 1.2.0

**Bugfixes**
Persist the application data directory. `/var/netrisk` was not a volume, so every
time a container was recreated — an image bump, a `docker rm`, a host rebuild —
the credential encryption key was discarded and every stored integration
credential (Slack/Teams webhooks, Jira and Azure DevOps tokens, Trend Micro and
SecurityScorecard API keys, OIDC client secrets, FaceID templates) had to be
re-entered. The api, console and backgroundjobs containers now bind-mount a
per-service `appdata` directory (mode `0700`) at `/var/netrisk`.

**Features**
New optional `secret_master_key` parameter. When set it is passed to the api,
console and backgroundjobs containers as `FACTER_SECRET_MASTER_KEY`, so the key
can come from Hiera (eyaml) or a vault instead of being host state. It must be
the base64 encoding of 32 bytes (`openssl rand -base64 32`) and is rejected at
compile time otherwise.


## Release 1.1.3

**Changed**
Migrate module tooling from PDK to Regent (removed pdk.yaml/.sync.yml/Gemfile/binstubs, added AGENTS.md, regent-based Rakefile and dev docs).


## Release 0.6.1

**Features**
Including backups


## Release 0.5.2-3

**Bugfixes**
Fix sp_certificate

## Release 0.5.1

**Features**
Including SAML support

## Release 0.4.10-11

**Bugfixes**
Fix netrisk-console parameter passing

## Release 0.4.7-9

**Bugfixes**
netrisk-console template

## Release 0.4.6

**Features**
Including shortcut to consoleclient command

## Release 0.4.5

**Bugfixes**
Fix directory ownership

## Release 0.4.4

**Bugfixes**
Website starting parameters

## Release 0.4.3

**Bugfixes**
Website starting parameters


## Release 0.4.2

**Bugfixes**
Console starting 


## Release 0.4.1

**Features**
Including background jobs installation


## Release 0.3.2

**Bugfixes**
Log mapping

## Release 0.3.1

**Features**
Log mapping


## Release 0.2.1

**Features**
Better code format
User ID parameters

## Release 0.1.8

**Bugfixes**

## Release 0.1.9

**Features**
User determination

## Release 0.1.8

**Bugfixes**
Small fix on mount points


## Release 0.1.5

**Features**

**Bugfixes**
Lint & tests

**Known Issues**

## Release 0.1.5

**Features**

**Bugfixes**
Docker network

**Known Issues**


## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
