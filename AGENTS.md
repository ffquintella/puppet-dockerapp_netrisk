# Agent Instructions for `dockerapp_netrisk`

These instructions apply to any AI agent (Claude Code, Copilot, Cursor, Aider, etc.)
working on this Puppet module. Human contributors should follow them too.

## What this module is

`dockerapp_netrisk` installs and configures the NetRisk application using Docker
images. The canonical interface is the manifests in `manifests/`, with EPP
templates in `templates/`, Hiera data in `data/`, and tests in `spec/`.

## Tooling: Regent, not PDK

This module is developed and tested with
[Regent](https://github.com/felipe-quintella/regent) — a self-contained,
Rust-based PDK alternative with an embedded Ruby runner. **Do not** reach for
`pdk`, `bundle exec`, or a host Ruby toolchain.

Typical loop:

```sh
regent validate   # parse manifests + metadata.json, lint
regent test       # run the rspec-puppet specs through the embedded runner
regent build      # produce a Forge-ready tarball in pkg/
regent fixtures   # install the modules declared in .fixtures.yml
```

If `regent test` reports a missing gem, run `regent bootstrap` — never
`gem install` or `bundle install`. Regent ships every gem it needs.

### Spec matcher notes

Regent's runner translates rspec-puppet specs into its own evaluator and
supports a subset of matchers: `compile`, `compile.and_raise_error(/.../)`, and
`contain_<type>('title').with(...)`. Avoid chains it does not parse (e.g.
`compile.with_all_deps`).

## How to work on it agentically

1. **Read first.** Before editing, scan `metadata.json`, `manifests/init.pp`,
   and any class/template you are about to touch. Match the existing style —
   parameter ordering, data types, the `FACTER_*` env var conventions.
2. **Small, focused changes.** One concern per change.
3. **Update tests alongside code.** New parameters or resources should be
   covered by the spec under `spec/classes/`.
4. **Keep `metadata.json` honest.** Update `dependencies`,
   `operatingsystem_support`, and `requirements` when the surface area changes.
   Bump `version` for releases.

## Pull request checklist

- [ ] `regent validate` is clean.
- [ ] `regent test` passes locally.
- [ ] `metadata.json` reflects new dependencies / OS support.
- [ ] No new dependency on a host Ruby, `bundle`, or `pdk`.

## Out of scope

- Introducing tooling that requires a host Ruby/Bundler install.
- Editing files under `pkg/` by hand — that directory is build output.
