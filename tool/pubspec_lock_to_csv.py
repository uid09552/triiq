#!/usr/bin/env python3
"""Lists every Dart/Flutter package in pubspec.lock as CSV.

Complements the SBOM: a flat, human-readable inventory of the exact versions the
app is built from (direct, dev and transitive), with where each comes from and
its content hash. No third-party libraries: pubspec.lock is a regular layout.

    python3 tool/pubspec_lock_to_csv.py pubspec.lock > dependencies.csv
"""
import csv
import re
import sys


def parse(text):
    """Yields one dict per package of the `packages:` section."""
    package = None
    in_packages = False
    in_description = False
    for line in text.splitlines():
        if re.match(r"^packages:\s*$", line):
            in_packages = True
            continue
        if re.match(r"^\S", line):  # another top-level section (sdks:)
            in_packages = False
        if not in_packages:
            continue
        m = re.match(r"^  ([^\s:][^:]*):\s*$", line)
        if m:
            if package:
                yield package
            package = {"name": m.group(1).strip('"'), "scope": "", "version": "",
                       "source": "", "url": "", "sha256": ""}
            in_description = False
            continue
        if package is None:
            continue
        m = re.match(r"^    (\w+):\s*(.*)$", line)
        if m:
            key, value = m.group(1), m.group(2).strip().strip('"')
            in_description = key == "description"
            if key == "dependency":
                package["scope"] = value
            elif key == "version":
                package["version"] = value
            elif key == "source":
                package["source"] = value
            continue
        m = re.match(r"^      (\w+):\s*(.*)$", line)
        if m and in_description:
            key, value = m.group(1), m.group(2).strip().strip('"')
            if key == "url":
                package["url"] = value
            elif key == "sha256":
                package["sha256"] = value
            elif key == "path" and not package["url"]:
                package["url"] = value
    if package:
        yield package


def main(argv):
    if len(argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    with open(argv[1], encoding="utf-8") as f:
        packages = sorted(parse(f.read()), key=lambda p: (p["scope"], p["name"]))
    if not packages:
        print("no packages found in " + argv[1], file=sys.stderr)
        return 1
    out = csv.writer(sys.stdout, lineterminator="\n")
    out.writerow(["name", "version", "scope", "source", "url", "sha256"])
    for p in packages:
        out.writerow([p["name"], p["version"], p["scope"], p["source"], p["url"], p["sha256"]])
    counts = {}
    for p in packages:
        counts[p["scope"]] = counts.get(p["scope"], 0) + 1
    print("packages: %d (%s)" % (len(packages), ", ".join(
        "%s %d" % (k, v) for k, v in sorted(counts.items()))), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
