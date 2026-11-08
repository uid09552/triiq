#!/usr/bin/env python3
"""Fails when a generated SBOM is missing or has no Dart packages, so an empty
scan (a renamed lockfile, a changed scanner) can't be published as if it were
complete. Checks the CycloneDX and SPDX files against pubspec.lock.

    python3 tool/check_sbom.py pubspec.lock sbom/triiq.cdx.json sbom/triiq.spdx.json
"""
import json
import re
import sys


def lock_names(path):
    text = open(path, encoding="utf-8").read()
    in_packages, names = False, set()
    for line in text.splitlines():
        if re.match(r"^packages:\s*$", line):
            in_packages = True
        elif re.match(r"^\S", line):
            in_packages = False
        elif in_packages:
            m = re.match(r"^  ([^\s:][^:]*):\s*$", line)
            if m:
                names.add(m.group(1).strip('"'))
    return names


def cyclonedx_names(path):
    data = json.load(open(path, encoding="utf-8"))
    return {c["name"] for c in data.get("components", []) if c.get("name")}


def spdx_names(path):
    data = json.load(open(path, encoding="utf-8"))
    return {p["name"] for p in data.get("packages", []) if p.get("name")}


def main(argv):
    if len(argv) != 4:
        print(__doc__, file=sys.stderr)
        return 2
    expected = lock_names(argv[1])
    if not expected:
        print("pubspec.lock lists no packages", file=sys.stderr)
        return 1
    failed = False
    for label, loader, path in (
        ("CycloneDX", cyclonedx_names, argv[2]),
        ("SPDX", spdx_names, argv[3]),
    ):
        try:
            found = loader(path)
        except (OSError, ValueError) as error:
            print("%s: cannot read %s: %s" % (label, path, error), file=sys.stderr)
            failed = True
            continue
        missing = expected - found
        # Tolerate a few the scanner folds away (the sdk pseudo-packages), but
        # not a scan that lost most of the lockfile.
        share = 1 - len(missing) / len(expected)
        print("%s: %d of %d lockfile packages present (%.0f%%)" % (
            label, len(expected) - len(missing), len(expected), share * 100))
        if share < 0.9:
            print("%s: too many missing, e.g. %s" % (
                label, ", ".join(sorted(missing)[:8])), file=sys.stderr)
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
