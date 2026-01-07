# CI Scripts

This directory contains scripts used for continuous integration and development workflows.

## Dependency Management Scripts

### `pub_get.sh`
**Use in CI/CD workflows for reproducible builds.**

This script runs `flutter pub get` for all packages in the repository. It respects the lockfiles (`pubspec.lock`) and ensures that builds are reproducible by using the exact versions specified in the lockfiles.

**When to use:**
- In GitHub Actions workflows (presubmit, postsubmit, releases)
- When you want to install dependencies without updating them
- When you need reproducible builds with consistent dependency versions

### `pub_upgrade.sh`
**Use for manual dependency updates by developers.**

This script runs `flutter pub upgrade` for all packages in the repository. It updates dependencies to their latest compatible versions and modifies the lockfiles.

**When to use:**
- When you want to update dependencies to their latest versions
- During local development when you need to upgrade packages
- When preparing a dependency update PR

**Note:** Do not use this in CI/CD workflows as it breaks reproducibility.

## Other Scripts

### `testing.sh`
Runs all tests in the repository with coverage.

### `update_assets.sh`
Updates assets in the repository.

### `rename_package_name_F-Droid.sh`
Renames package name for F-Droid builds.
