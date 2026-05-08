Building the package:
melange build melange/dasel.yaml \
  --arch amd64 \
  --signing-key melange.rsa \
  --repository-append https://packages.wolfi.dev/os \
  --keyring-append https://packages.wolfi.dev/os/wolfi-signing.rsa.pub


Building the image:
apko build apko/dasel.yaml dasel:3.3.1-patched dasel.tar


Tests:

1.
Loading the image in docker:
docker load < dasel.tar

2.
Running tests:
chmod +x tests/test.sh && ./tests/test.sh