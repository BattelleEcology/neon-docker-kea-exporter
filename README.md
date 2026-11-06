# kea-prometheus-exporter
ISC kea dhcp exporter for prometheus metrics

## Dependencies

Python dependencies are declared in `pyproject.toml` and pinned in `uv.lock`.
To update them by hand, run `uv lock --upgrade`.

Renovate (`.github/renovate.json5`) keeps `uv.lock`, `.python-version`, the
`Dockerfile` images and the GitHub Actions up to date, and automerges each PR
once its build passes.

## Releases

Every build of `main` is tagged with the kea-exporter version from `uv.lock`
and the Alpine tag from the `Dockerfile`: `v<kea-exporter>-alpine<alpine>`
(e.g. `v0.7.1-alpine3.24.3`) and `v<kea-exporter>` (e.g. `v0.7.1`). The first
successful publish of each release also tags the repo `v<kea-exporter>-alpine<alpine>`.
The image installs Python itself with uv, using the version in `.python-version`.
