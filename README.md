# Build Package

```bash
melange build melange/dasel.yaml \
  --arch amd64 \
  --signing-key melange.rsa \
  --repository-append https://packages.wolfi.dev/os \
  --keyring-append https://packages.wolfi.dev/os/wolfi-signing.rsa.pub
```

# Test Package

```bash
melange test melange/dasel.yaml \
  --arch amd64 \
  --repository-append ./packages \
  --keyring-append ./melange.rsa.pub \
  --repository-append https://packages.wolfi.dev/os \
  --keyring-append https://packages.wolfi.dev/os/wolfi-signing.rsa.pub
```

# Build Image

```bash
apko build apko/dasel.yaml dasel:3.3.1-patched dasel.tar
```

# Load Image and Run Tests

```bash
docker load < dasel.tar && chmod +x tests/test.sh && ./tests/test.sh
```