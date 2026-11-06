# AGENTS.md

Guidance for coding agents working in this repository.

## What this repo is

A container image that packages the upstream [`kea-exporter`](https://pypi.org/project/kea-exporter/)
(Prometheus exporter for ISC Kea DHCP) from PyPI. There is no Python source of its own:
`pyproject.toml` has `package = false` and only declares the `kea-exporter` dependency.
The deliverable is the `Dockerfile` plus the CI and Renovate config that release it.

## Commands

```sh
docker build -t kea-exporter .              # build the image (also runs the smoke test)
docker run --rm kea-exporter --help         # entrypoint is kea-exporter
uv lock --upgrade                           # refresh uv.lock by hand
```

There are no tests or linters. The only check is the `kea-exporter --help` smoke test
inside the Dockerfile's build stage, which fails the build if the stripped Python can't
run the exporter.

## Where versions come from

Each version has exactly one source, and CI reads them from there:

- **kea-exporter**: `uv.lock`. `pyproject.toml` only sets a floor (`>=`), so upgrades
  change the lock file alone.
- **Alpine**: the two `FROM alpine:<tag>` lines in the `Dockerfile`. They must match;
  the `plan` job fails if it finds more than one tag.
- **Python**: `.python-version`, installed by uv in the build stage (not apk).
- **uv**: the `FROM ghcr.io/astral-sh/uv:<tag> AS uv` stage.

## Dockerfile structure

- Build stage on Alpine: uv installs Python into `/opt/python`, `uv sync` builds the venv
  at `/usr/app/.venv`, then unused parts of Python (pip, Tcl/Tk, IDLE, headers,
  shared libpython, ...) are deleted. The paths use `python3.*` globs so a Python bump
  needs no edit here.
- Final stage on Alpine: copies `/opt/python` and `/usr/app` at the same paths (the venv's
  `python` links into the uv-managed install), runs as non-root user `kea`.
- Bytecode is compiled at build time because the runtime user can't write `.pyc` files.

## Release flow

- Renovate (`.github/renovate.json5`) groups Alpine, uv, Python and kea-exporter into one
  `image` PR, groups GitHub Actions into another, and automerges each once its PR build
  passes (`platformAutomerge: false`, because the org ruleset requires no status checks).
- `.github/workflows/docker-publish.yml` builds with `docker/github-builder` (linux/amd64)
  and pushes to GCP Artifact Registry (WIF) and ghcr.io. Builds of `main` are tagged
  `v<kea-exporter>-alpine<alpine>` and `v<kea-exporter>`; version tags need the `v`
  prefix to survive the shared registry's cleanup rules.
- After a `main` build, the `tag` job tags the repo `v<kea-exporter>-alpine<alpine>` via
  `gh api`, skipping tags that already exist. Nobody tags by hand.
- `GITHUB_TOKEN` can't create a tag on a commit that changes `.github/workflows/`
  (HTTP 403). Keep version bumps out of PRs that change workflows.
- A Trivy scan runs on pushed images and uploads SARIF to the Security tab.
