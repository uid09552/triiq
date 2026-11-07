# Releases

Builds are published on the
[GitHub Releases page](https://github.com/uid09552/triiq/releases).

| Kind | Tag | When |
|---|---|---|
| **Release candidate** (pre-release) | `v<version>-rc<commit>`, e.g. `v0.9.1-rc1a2b3c4` | Automatically on every merge to `main` |
| **Release** | the tag pushed, e.g. `v1.0.0` | When a maintainer pushes a `v*` tag (a tag with `-`, e.g. `v1.0.0-beta1`, is a pre-release) |

- The `<version>` comes from `version:` in `pubspec.yaml` (currently `0.9.1`).
- The APK's version name is the tag without the `v`; the version code is the
  build number, so newer builds install over older ones.
- Automatic release candidates older than **3 days** are deleted daily; the
  **newest one always stays**. Tagged releases and your own pre-releases are
  never removed.
- Builds are signed with the project's release key, so updates install over
  an existing copy.

For maintainers, the workflows are `.github/workflows/android-release.yml`
and `.github/workflows/cleanup-prereleases.yml`; `[skip release]` in a merge
commit message skips the automatic release.
