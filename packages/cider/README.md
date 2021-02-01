
This is a fork from 






![logo]  
# Cider (CI for Dart. Efficient Release)
A command-line utility to automate package maintenance. Manipulates the changelog and pubspec.yaml.

This tool assumes that the changelog:
 - is called `CHANGELOG.md`
 - is sitting in the project root folder
 - strictly follows the [Keep a Changelog v1.0.0](https://keepachangelog.com/en/1.0.0/) format
 - uses basic markdown (no HTML and complex formatting supported) 
 
It also assumes that your project follows [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html).

## Install
```
pub global activate cider
```

## Configure
The config file name is `.cider.yaml`. It should reside in the root folder of the project. This file is optional. 
So far it consists of just a single entry.
```yaml
changelog:
  diff_link_template: 'https://github.com/org/project/compare/%from%...%to%'
```

The `%from%` and `%to%` placeholders will be replaced with the corresponding version tags.

## Updating the changelog
This command will add a new line to the `Unreleased` section of the changelog
```
cider log <type> <description>
```
 - **type** is one of: `added`, `changed`, `deprecated`, `removed`, `fixed`, `security`
 - **description** is a markdown text line

Examples
```
cider log change 'New turbo engine installed'
cider log add 'Support for rocket fuel and kerosene'
cider log fix 'No more wheels falling off'
```

## Releasing the unreleased changes
This command takes all changes from the `Unreleased` section on the changelog and creates a new release with the
version from pubspec.yaml

```
cider release
```

Use `--date` to provide the release date (the default is today).

Cider will automatically generate the diff links in the changelog if the diff link template is found in the config.


## Setting the project version
```
cider set <new_version>
cider version <new_version>
```
- **new_version** must be semver-compatible

Version before | Command | Version after
--- | --- | ---
1.2.3 | `cider set 3.2.1`  | 3.2.1
0.2.1 | `cider set 0.0.1-dev`  | 0.0.1-dev
--- | --- | ---
1.2.3 | `cider version 3.2.1`  | 3.2.1
0.2.1 | `cider version test/0.0.1-dev`  | 0.0.1



## Bumping the project version
```
cider bump <version>
```
- **version** can be any of: `breaking`, `major`, `minor`, `patch`, `build`

Use `--keep-build` or `-b` to retain the build part of the version.
Use `--keep-pre-release` or `-r` to retain the pre-release part of the version.

Use `--print` or `-p` to print the new version.

Version before | Command | Version after
--- | --- | ---
1.2.3 | `cider bump breaking`  | 2.0.0
0.2.1 | `cider bump breaking`  | 0.3.0
0.2.1 | `cider bump major`     | 1.0.0
0.2.1 | `cider bump minor`     | 0.3.0
0.2.1 | `cider bump patch`     | 0.2.2
0.2.1 | `cider bump build`     | 0.2.1+1
0.2.1+42 | `cider bump build`     | 0.2.1+43
0.2.1+foo | `cider bump build`     | 0.2.1+foo.1
0.2.1+42.foo | `cider bump build`     | 0.2.1+43.foo
0.2.1+foo.bar.1.2 | `cider bump build`     | 0.2.1+foo.bar.2.0

The `cider bump build` command is a bit tricky. It either increments the first numeric part of the build (if there is a 
numeric part) setting other numeric parts to zeroes, or appends `.1` to the build (otherwise).

Retaining the build part:

Version before | Command | Version after
--- | --- | ---
1.2.3+42 | `cider bump breaking`       | 2.0.0
0.2.1+42 | `cider bump breaking -b`    | 0.3.0+42
0.2.1+42 | `cider bump patch`          | 0.2.2
0.2.1+42 | `cider bump patch -b`       | 0.2.2+42

## Printing the current project version
```
cider version
```

## Printing the list of changes in the given version
```
cider describe <version>
```
- **version** is an existing version from the changelog

[logo]: https://raw.githubusercontent.com/f3ath/cider/master/cider.png