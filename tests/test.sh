#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-dasel:3.3.1-patched-amd64}"

echo "== Test 1: dasel binary is runnable =="
docker run --rm "$IMAGE" version

echo "== Test 2: JSON query from stdin works =="
json_output="$(
  echo '{"foo": {"bar": "baz"}}' \
  | docker run --rm -i "$IMAGE" query -i json 'foo.bar'
)"

if [ "$json_output" != '"baz"' ]; then
  echo "Expected: \"baz\""
  echo "Got: $json_output"
  exit 1
fi

echo "== Test 3: YAML query from stdin works =="
yaml_output="$(
  printf 'foo:\n  bar: baz\n' \
  | docker run --rm -i "$IMAGE" query -i yaml 'foo.bar'
)"

if [ "$yaml_output" != "baz" ]; then
  echo "Expected: baz"
  echo "Got: $yaml_output"
  exit 1
fi

echo "== Test 4: CVE-2026-33320 alias bomb is rejected quickly =="
payload='a: &a ["lol","lol","lol","lol","lol","lol","lol","lol","lol"]
b: &b [*a,*a,*a,*a,*a,*a,*a,*a,*a]
c: &c [*b,*b,*b,*b,*b,*b,*b,*b,*b]
d: &d [*c,*c,*c,*c,*c,*c,*c,*c,*c]
e: &e [*d,*d,*d,*d,*d,*d,*d,*d,*d]
f: &f [*e,*e,*e,*e,*e,*e,*e,*e,*e]
g: &g [*f,*f,*f,*f,*f,*f,*f,*f,*f]
h: &h [*g,*g,*g,*g,*g,*g,*g,*g,*g]
i: &i [*h,*h,*h,*h,*h,*h,*h,*h,*h]
'

set +e
cve_output="$(
  printf "%s" "$payload" \
  | timeout 5s docker run --rm -i "$IMAGE" query -i yaml 'i' 2>&1
)"
status=$?
set -e

if [ "$status" -eq 124 ]; then
  echo "CVE test failed: command timed out, possible unbounded expansion"
  exit 1
fi

if [ "$status" -eq 0 ]; then
  echo "CVE test failed: expected malicious YAML to be rejected"
  exit 1
fi

if ! echo "$cve_output" | grep -qi "expansion budget exceeded"; then
  echo "CVE test failed: unexpected error output"
  echo "$cve_output"
  exit 1
fi

echo "CVE test passed: malicious YAML was rejected before timeout"
echo "All tests passed."