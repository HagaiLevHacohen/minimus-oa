How to build the package:
melange build melange/dasel.yaml \
  --arch amd64 \
  --repository-append https://packages.wolfi.dev/os \
  --keyring-append https://packages.wolfi.dev/os/wolfi-signing.rsa.pub

