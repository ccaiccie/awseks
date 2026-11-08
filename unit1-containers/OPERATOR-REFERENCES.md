# Operator references (companion only; not narrated)

These were used to write or check the practice steps. Learners do not need them to follow the guide.

- Docker Desktop install, Windows (WSL 2 backend, virtualization requirements): https://docs.docker.com/desktop/setup/install/windows-install/
- Docker Desktop install, Mac: https://docs.docker.com/desktop/setup/install/mac-install/
- Docker Engine install, Linux: https://docs.docker.com/engine/install/
- Linux post-install (`docker` group is root-equivalent; running without sudo): https://docs.docker.com/engine/install/linux-postinstall/
- Docker Desktop networking: the engine runs in a Linux VM, and published ports bind to all interfaces unless an address is given: https://docs.docker.com/desktop/features/networking/
- Publishing ports, `-p [host-ip:]host-port:container-port`; EXPOSE does not publish: https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/
- Dockerfile reference (FROM, WORKDIR, COPY multi-source destination with trailing `/`, RUN, ENV, EXPOSE, CMD exec form): https://docs.docker.com/reference/dockerfile/
- `.dockerignore`: https://docs.docker.com/build/concepts/context/#dockerignore-files
- `docker container stop`, SIGTERM then SIGKILL after the timeout: https://docs.docker.com/reference/cli/docker/container/stop/
- `docker container update`, CPU/memory limits on a running container: https://docs.docker.com/reference/cli/docker/container/update/
- Docker subscription terms (Docker Desktop commercial use): https://www.docker.com/pricing/faq/
- Official Python image, `python:3.12-slim` (multi-arch): https://hub.docker.com/_/python
- Flask quickstart (default 127.0.0.1:5000; `host=` for external; development-server caveat; debugger risk): https://flask.palletsprojects.com/en/stable/quickstart/
- Flask deploying (do not use the development server in production): https://flask.palletsprojects.com/en/stable/deploying/
- Python `venv`: https://docs.python.org/3/library/venv.html
- pip requirements files: https://pip.pypa.io/en/stable/user_guide/#requirements-files
- curl in Windows (`curl.exe` ships with Windows 10 1803+ / 11): https://curl.se/windows/microsoft.html
- PyPI pins verified 2026-11-07: Flask 3.1.3 (https://pypi.org/project/Flask/3.1.3/), Werkzeug 3.1.9 (https://pypi.org/project/Werkzeug/3.1.9/)
