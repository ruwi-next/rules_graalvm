#!/bin/bash

set -euo pipefail

INPUT_VERSION="24.2.2+1-24.0.2+13"

NIK_FULL_VERSION=$(printf %s $INPUT_VERSION | cut -d "-" -f 1)
NIK_VERSION=$(printf %s $NIK_FULL_VERSION | cut -d "+" -f 1)
NIK_VERSION_EXTRA=$(printf %s $NIK_FULL_VERSION | cut -d "+" -f 2)
JAVA_VERSION=$(printf %s $INPUT_VERSION | cut -d "-" -f 2)
JAVA_MAJOR_VERSION=$(printf %s $JAVA_VERSION | cut -d "." -f 1)
VERSION="${NIK_FULL_VERSION}-${JAVA_VERSION}"

echo $VERSION

URL_VERSION=$(printf %s $VERSION | jq -sRr @uri)
RELEASE_JSON=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/bell-sw/LibericaNIK/releases/tags/$URL_VERSION)

printf %s $RELEASE_JSON | jq --arg JAVA_MAJOR_VERSION $JAVA_MAJOR_VERSION --arg NIK_VERSION $NIK_VERSION --indent 4 '{
  ("nik_" + $NIK_VERSION + "_linux-x64_" + $NIK_VERSION): [.assets.[] | select(.name | test("^bellsoft-liberica-vm-full-openjdk(.+)-linux-amd64.tar.gz"))][0] | {
    "url": .browser_download_url,
    "sha256": .digest // "" | sub("^sha256:"; ""),
    "compatible_with": [
      "@platforms://cpu:x86_64",
      "@platforms//os:linux",
      "@rules_graalvm//platform/jvm:java" + $JAVA_MAJOR_VERSION
    ],
  },
  ("nik_" + $NIK_VERSION + "_linux-aarch64_" + $NIK_VERSION): [.assets.[] | select(.name | test("^bellsoft-liberica-vm-full-openjdk(.+)-linux-aarch64.tar.gz"))][0] | {
    "url": .browser_download_url,
    "sha256": .digest // "" | sub("^sha256:"; ""),
    "compatible_with": [
      "@platforms://cpu:aarch64",
      "@platforms//os:linux",
      "@rules_graalvm//platform/jvm:java" + $JAVA_MAJOR_VERSION
    ],
  },
  ("nik_" + $NIK_VERSION + "_windows-x64_" + $NIK_VERSION): [.assets.[] | select(.name | test("^bellsoft-liberica-vm-full-openjdk(.+)-windows-amd64.zip"))][0] | {
    "url": .browser_download_url,
    "sha256": .digest // "" | sub("^sha256:"; ""),
    "compatible_with": [
      "@platforms://cpu:x86_64",
      "@platforms//os:windows",
      "@rules_graalvm//platform/jvm:java" + $JAVA_MAJOR_VERSION
    ],
  },
  ("nik_" + $NIK_VERSION + "_macos-x64_" + $NIK_VERSION): [.assets.[] | select(.name | test("^bellsoft-liberica-vm-full-openjdk(.+)-macos-amd64.tar.gz"))][0] | {
    "url": .browser_download_url,
    "sha256": .digest // "" | sub("^sha256:"; ""),
    "compatible_with": [
      "@platforms://cpu:x86_64",
      "@platforms//os:macos",
      "@rules_graalvm//platform/jvm:java" + $JAVA_MAJOR_VERSION
    ],
  },
  ("nik_" + $NIK_VERSION + "_macos-aarch64_" + $NIK_VERSION): [.assets.[] | select(.name | test("^bellsoft-liberica-vm-full-openjdk(.+)-macos-aarch64.tar.gz"))][0] | {
    "url": .browser_download_url,
    "sha256": .digest // "" | sub("^sha256:"; ""),
    "compatible_with": [
      "@platforms://cpu:aarch64",
      "@platforms//os:macos",
      "@rules_graalvm//platform/jvm:java" + $JAVA_MAJOR_VERSION
    ],
  },
}'
