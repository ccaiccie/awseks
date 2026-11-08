# Base image: small Debian-based Linux userspace with Python 3.12 (official image).
FROM python:3.12-slim

# Folder inside the image where our files live.
WORKDIR /app

# Library layer: copy only the list first so this layer is reused when only code changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Our own files: the top layer.
COPY server.py greeting.txt ./

# Listen on the container's own network interface, not only its loopback.
ENV HOST=0.0.0.0

# Documents the listen port. It does not publish anything by itself.
EXPOSE 8080

# Default start command stored in the image.
CMD ["python", "server.py"]
