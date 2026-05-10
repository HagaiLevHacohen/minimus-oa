# Dasel Packaging Assignment

# Explanation

## Introduction

This repository contains:

- A Melange package definition for `dasel` v3.3.1
- An apko image definition that installs the locally built APK
- A patch fixing CVE-2026-33320
- Runtime tests validating both normal functionality and the CVE mitigation

---

## CVE-2026-33320 Fix

`dasel` v3.3.1 is vulnerable to unbounded YAML alias expansion, which can cause excessive CPU and memory consumption.

The vulnerability originates from recursively resolving YAML aliases (`yaml.AliasNode`) without enforcing any expansion limit. A malicious YAML document can repeatedly reference aliases in a nested manner, causing exponential expansion and potentially leading to denial-of-service conditions through excessive recursion and resource consumption.

The fix implemented in this repository introduces two protections:

1. **Expansion Budget**
   - A shared alias expansion counter is maintained during parsing.
   - Each alias resolution decreases the remaining budget.
   - Once the configured limit is exceeded, parsing fails with:
     ```text
     yaml expansion budget exceeded
     ```

2. **Expansion Depth Limit**
   - Recursive alias expansion depth is tracked during parsing.
   - If alias nesting becomes too deep, parsing fails with:
     ```text
     yaml expansion depth exceeded
     ```

Together, these limits prevent uncontrolled recursive alias expansion while still allowing normal YAML alias functionality.

Patch location:

```text
melange/patches/CVE-2026-33320.patch
```

---

## Repository Structure

```text
melange/
├── dasel.yaml
└── patches/
    └── CVE-2026-33320.patch

apko/
└── dasel.yaml

tests/
└── test.sh

README.md
```

---

# Commands

## Generate Signing Keys

```bash
melange keygen
```

This generates:

```text
melange.rsa
melange.rsa.pub
```

---

## Build Package

```bash
melange build melange/dasel.yaml \
  --arch amd64 \
  --signing-key melange.rsa \
  --repository-append https://packages.wolfi.dev/os \
  --keyring-append https://packages.wolfi.dev/os/wolfi-signing.rsa.pub
```

## Test Package

```bash
melange test melange/dasel.yaml \
  --arch amd64 \
  --repository-append ./packages \
  --keyring-append ./melange.rsa.pub \
  --repository-append https://packages.wolfi.dev/os \
  --keyring-append https://packages.wolfi.dev/os/wolfi-signing.rsa.pub
```

## Build Image

The apko image installs the locally built patched package from `./packages`.

```bash
apko build apko/dasel.yaml dasel:3.3.1-patched dasel.tar
```

## Load Image and Run Tests

```bash
docker load < dasel.tar && chmod +x tests/test.sh && ./tests/test.sh
```

---

## Notes

Assumptions:
- Docker is available locally.
- melange and apko are installed.
- Commands were tested on Linux (Ubuntu/Xubuntu).

Result:
- Package build passed.
- Package test passed.
- apko image build passed.
- Image tests passed.

With more time, I would add more dasel behavior tests and test the CVE fix at the package-test level as well.