# Changelog

All notable changes to this project will be documented in this file.

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
