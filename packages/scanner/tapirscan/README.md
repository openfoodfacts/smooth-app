# scanner_tapirscan

Scanner implementation using [Tapirscan](https://github.com/kleinicke/tapirscan)
(medium effort), next to `scanner_ml_kit` and `scanner_zxing`, to compare them
on real phones. It reads the same formats as the other two (EAN-8/13, UPC-A/E,
ITF, Code 39/93/128, Data Matrix, QR).

Frames come from the `camera` plugin. Their Y plane goes to Tapirscan's Dart
package (`dart:ffi`), one frame at a time on a background isolate. There is no
platform code in this package.

## Tapirscan dependency

[`tapirscan`](https://pub.dev/packages/tapirscan) downloads its native library
for each target from the matching GitHub release on the first build and checks
it against the checksums shipped in the package. No Rust or NDK setup is needed.
To build the library from source instead (for example for F-Droid), set
`source_dir` to a Tapirscan checkout, see the package's
[setup](https://github.com/kleinicke/tapirscan/tree/v1.5.0/bindings/flutter#setup).

Supported: 64-bit Android (arm64-v8a, x86_64). On 32-bit Android there is no
Tapirscan library: the camera view stays empty and the error is logged.

## Build the app with Tapirscan

From the repository root:

```sh
./ci/dependencies/scanner/enable_tapirscan_dependency.sh
cd packages/smooth_app
fvm flutter pub get
fvm flutter build apk --debug --target-platform android-arm64,android-x64 --target lib/entrypoints/android/main_tapirscan.dart
```

The script disables ML Kit and ZXing, enables this package and writes the
`main_tapirscan.dart` entrypoint.

## Tests

`flutter test` decodes a padded camera Y plane with the scanner's options.
