# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [0.0.5] - 2020-09-09
### Added
- Setting version explicitly
- Ability to retain pre-release part of the version

## [0.0.4] - 2020-08-10
### Changed
- Using a yaml manipulation library to updatd pubspec.yaml. This expected to be more reliable than a regexp.

## [0.0.3] - 2020-08-09
### Changed
- Using a regex instead of yaml parser to modify pubspec.yaml. This should preserve existing file formatting

## [0.0.2+1] - 2020-07-29
### Fixed
- Fixed [\#1](https://github.com/f3ath/cider/issues/1) by downgrading the `path` dependency

## [0.0.2] - 2020-07-26
### Changed
- Updated the dependencies

## [0.0.1+2] - 2020-07-26
### Fixed
- Readme improvements

## [0.0.1+1] - 2020-07-26
### Fixed
- Code formatting to improve pub scores

## [0.0.1] - 2020-07-26
### Added
- Minor documentation improvements

### Fixed
- Usage exception does not print trace logs anymore

## [0.0.0+dev.2] - 2020-07-24
### Changed
- Updated dependencies

## 0.0.0+dev.1 - 2020-07-23
### Added
- Initial version

[Unreleased]: https://github.com/f3ath/cider/compare/0.0.5...HEAD
[0.0.5]: https://github.com/f3ath/cider/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/f3ath/cider/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/f3ath/cider/compare/0.0.2+1...0.0.3
[0.0.2+1]: https://github.com/f3ath/cider/compare/0.0.2...0.0.2+1
[0.0.2]: https://github.com/f3ath/cider/compare/0.0.1+2...0.0.2
[0.0.1+2]: https://github.com/f3ath/cider/compare/0.0.1+1...0.0.1+2
[0.0.1+1]: https://github.com/f3ath/cider/compare/0.0.1...0.0.1+1
[0.0.1]: https://github.com/f3ath/cider/compare/0.0.0+dev.2...0.0.1
[0.0.0+dev.2]: https://github.com/f3ath/cider/compare/0.0.0+dev.1...0.0.0+dev.2