#!/usr/bin/env python3
"""Writes a CycloneDX 1.5 JSON SBOM of every Dart/Flutter package in
pubspec.lock to stdout. The app bundles the result as
assets/sbom/triiq.cdx.json (Info -> Software Bill of Materials), so the file is
deterministic: no timestamp, no serial number, packages sorted by name. CI
regenerates it and fails when the committed copy differs.

    python3 tool/pubspec_lock_to_cdx.py pubspec.lock pubspec.yaml \
        > assets/sbom/triiq.cdx.json

Per package: name, version, purl (pkg:pub/<name>@<version>), CycloneDX scope
(required: a main dependency or a transitive one; optional: a dev dependency),
SHA-256 of the package archive when the lockfile has it, and the properties
triiq:dependency (direct | dev | transitive) and triiq:source (hosted | sdk |
git | path). Native Android (Gradle) libraries and the Flutter engine are not
covered, as in the Syft SBOM of the SBOM workflow. Standard library only.
"""
import json
import re
import sys

from pubspec_lock_to_csv import parse

KIND = {
    "direct main": "direct",
    "direct overridden": "direct",
    "direct dev": "dev",
    "transitive": "transitive",
}


def pubspec_field(text, field):
    m = re.search(r"^%s:\s*(\S+)" % re.escape(field), text, re.M)
    return m.group(1).strip("\"'") if m else None


def build(lock_text, pubspec_text):
    name = pubspec_field(pubspec_text, "name") or "triiq"
    version = pubspec_field(pubspec_text, "version") or "0.0.0"
    components = []
    for p in sorted(parse(lock_text), key=lambda p: p["name"]):
        kind = KIND.get(p["scope"], "transitive")
        purl = "pkg:pub/%s@%s" % (p["name"], p["version"])
        component = {
            "type": "library",
            "bom-ref": purl,
            "name": p["name"],
            "version": p["version"],
            "scope": "optional" if kind == "dev" else "required",
            "purl": purl,
        }
        if p["sha256"]:
            component["hashes"] = [{"alg": "SHA-256", "content": p["sha256"]}]
        component["properties"] = [
            {"name": "triiq:dependency", "value": kind},
            {"name": "triiq:source", "value": p["source"] or "unknown"},
        ]
        components.append(component)
    return {
        "bomFormat": "CycloneDX",
        "specVersion": "1.5",
        "version": 1,
        "metadata": {
            "tools": {"components": [{
                "type": "application",
                "name": "tool/pubspec_lock_to_cdx.py",
            }]},
            "component": {
                "type": "application",
                "bom-ref": "pkg:pub/%s@%s" % (name, version),
                "name": name,
                "version": version,
            },
        },
        "components": components,
    }


def main(argv):
    if len(argv) != 3:
        print(__doc__, file=sys.stderr)
        return 2
    with open(argv[1], encoding="utf-8") as f:
        lock_text = f.read()
    with open(argv[2], encoding="utf-8") as f:
        pubspec_text = f.read()
    bom = build(lock_text, pubspec_text)
    if not bom["components"]:
        print("no packages found in " + argv[1], file=sys.stderr)
        return 1
    sys.stdout.write(json.dumps(bom, indent=2, ensure_ascii=False) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
