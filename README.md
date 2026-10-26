# kea-prometheus-exporter
ISC kea dhcp exporter for prometheus metrics

## Dependencies

Python dependencies are declared in `pyproject.toml` and pinned in `uv.lock`.
To update them, run `uv lock --upgrade`. Dependabot opens a single PR covering
both `uv.lock` and the `Dockerfile` base images.
The image installs Python itself with uv, using the version in `.python-version`.
