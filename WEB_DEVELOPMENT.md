# Running the Web Version

This guide explains how to run the experimental web version of the Smooth App locally.

## Prerequisites

- Flutter SDK 3.35.1 or later
- Chrome or another modern web browser

## Development Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/openfoodfacts/smooth-app.git
   cd smooth-app
   ```

2. **Install dependencies**:
   ```bash
   ./ci/pub_upgrade.sh
   ```

3. **Run the web version**:
   ```bash
   cd packages/smooth_app
   flutter run -d web-server --target=lib/entrypoints/web/main_web.dart
   ```

   Or to run on a specific port:
   ```bash
   flutter run -d web-server --web-port=8080 --target=lib/entrypoints/web/main_web.dart
   ```

## Building for Production

To build the web version for deployment:

```bash
cd packages/smooth_app
flutter build web --target=lib/entrypoints/web/main_web.dart --base-href="/smooth-app/"
```

The built files will be in `packages/smooth_app/build/web/`.

## Testing

### Manual Testing

1. Open the web app in your browser
2. Navigate to the scanner section
3. Enter a test barcode (e.g., `3017620422003` for Nutella)
4. Verify product information loads correctly

### Automated Testing

Run the web scanner tests:
```bash
cd packages/scanner/web_scanner
flutter test
```

## Development Notes

### Scanner Implementation

The current web scanner is a placeholder that accepts manual barcode input. Future development will integrate ZXingJS for camera-based scanning.

### Responsive Design

The web version should work on various screen sizes. Test on:
- Desktop browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers
- Tablet browsers in landscape mode

### Platform Differences

Some features may behave differently on web:
- File system access is limited
- Camera API works differently
- Platform-specific UI elements may not be available

## Troubleshooting

### Build Issues

If you encounter build errors:
1. Ensure you're using the correct Flutter version (`cat ../../flutter-version.txt`)
2. Clean the build cache: `flutter clean`
3. Regenerate dependencies: `flutter pub get`

### Runtime Issues

- **Scanner not working**: This is expected; use manual input
- **Missing fonts**: Check that web fonts are loading correctly
- **API errors**: Ensure you're connected to the internet

## Contributing

When working on web-specific features:
1. Test on multiple browsers
2. Verify responsive behavior
3. Consider progressive web app features
4. Follow the existing code style