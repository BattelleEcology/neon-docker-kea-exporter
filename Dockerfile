FROM ghcr.io/astral-sh/uv:0.13.7 AS uv

FROM alpine:3.24.4 AS build

COPY --from=uv /uv /bin/uv
# Python is installed by uv (version from .python-version) rather than apk. Bytecode is
# compiled at build time because the non-root user can't write .pyc files at runtime.
ENV UV_PYTHON_INSTALL_DIR=/opt/python \
    UV_PYTHON_PREFERENCE=only-managed \
    UV_PROJECT_ENVIRONMENT=/usr/app/.venv \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_CACHE=1
WORKDIR /usr/app
COPY .python-version pyproject.toml uv.lock /usr/app/
RUN uv python install &&\
    uv sync --locked --no-dev
# Shrink the image by removing parts of the Python install the exporter doesn't use:
# pip, Tcl/Tk, IDLE, headers, docs, and the shared libpython (the python binary is static).
# python3.* so a Python bump from Renovate doesn't need this edited.
RUN cd "$(dirname "$(dirname "$(readlink -f "$(uv python find)")")")" &&\
    rm -rf include share bin/idle* bin/pip* bin/pydoc* bin/*-config \
        lib/libpython* lib/libtcl* lib/tcl* lib/tk* lib/itcl* lib/thread* \
        lib/python3.*/config-* lib/python3.*/ensurepip lib/python3.*/idlelib \
        lib/python3.*/pydoc_data lib/python3.*/site-packages/pip* \
        lib/python3.*/tkinter lib/python3.*/turtledemo \
        lib/python3.*/lib-dynload/_tkinter*
# Smoke test: the PR build fails, so Renovate won't automerge, if the exporter
# can't start on the stripped Python
RUN /usr/app/.venv/bin/kea-exporter --help >/dev/null

FROM alpine:3.24.4

RUN addgroup -g 101 kea &&\
    adduser kea -G kea -S

# The venv's python links into the uv-managed install, so both keep their build paths
COPY --from=build /opt/python /opt/python
COPY --from=build /usr/app /usr/app

USER kea
ENV PATH="/usr/app/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ENTRYPOINT ["kea-exporter"]
