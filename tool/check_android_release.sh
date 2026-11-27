#!/usr/bin/env bash
# Checks a release APK against Play requirements (issue #110):
#  - targetSdkVersion >= 36 (required for updates since 31 Aug 2026): fails.
#  - 16 KB page size (required for updates from 1 Feb 2027): every native
#    library's ELF LOAD segments aligned to >= 16 KB, and the APK's .so
#    entries zip-aligned for 16 KB. Reported as a warning until then.
# Usage: tool/check_android_release.sh path/to/app-release.apk
set -euo pipefail
apk="$1"
bt="$(ls -d "${ANDROID_HOME:-$ANDROID_SDK_ROOT}"/build-tools/* | sort -V | tail -1)"

target="$("$bt/aapt2" dump badging "$apk" | sed -n "s/.*targetSdkVersion:'\([0-9]*\)'.*/\1/p")"
echo "targetSdkVersion: $target"
if [ "${target:-0}" -lt 36 ]; then
  echo "::error::targetSdkVersion $target is below 36 (Play requirement)"
  exit 1
fi

problems=0
if ! "$bt/zipalign" -c -P 16 4 "$apk" >/dev/null; then
  echo "::warning::APK native libraries are not zip-aligned for 16 KB pages"
  problems=1
fi
work="$(mktemp -d)"
unzip -q -o "$apk" 'lib/*' -d "$work" 2>/dev/null || true
while IFS= read -r so; do
  # The smallest LOAD alignment in the library, e.g. 0x4000 = 16 KB.
  align="$(readelf -lW "$so" | awk '$1=="LOAD"{print $NF}' | sort | head -1)"
  if [ -n "$align" ] && [ $((align)) -lt 16384 ]; then
    echo "::warning::${so#$work/} LOAD alignment $align is below 16 KB"
    problems=1
  fi
done < <(find "$work/lib" -name '*.so' 2>/dev/null)
rm -rf "$work"
if [ "$problems" = 0 ]; then
  echo "16 KB page size: OK"
else
  echo "16 KB page size: not ready (must be fixed before 1 Feb 2027)"
fi
