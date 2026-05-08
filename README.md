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



## Notes

Assumptions:
- Docker is available locally.
- melange and apko are installed.
- The repository includes a local signing key pair for package signing/testing convenience.

Result:
- Package build passed.
- Package test passed.
- apko image build passed.
- Image tests passed.

With more time, I would add more dasel behavior tests and test the CVE fix at the package-test level as well.
