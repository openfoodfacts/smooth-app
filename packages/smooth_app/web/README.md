# Web Deployment

This directory contains the web deployment configuration for the Open Food Facts Smooth App.

## Features

The experimental web version includes:
- Manual barcode input for testing products
- Responsive layout suitable for landscape formats  
- Web-compatible UI components
- GitHub Pages deployment

## Architecture

The web version uses:
- **Entry point**: `lib/entrypoints/web/main_web.dart`
- **Scanner**: `packages/scanner/web_scanner` - placeholder implementation with manual input
- **App Store**: URI-based store pointing to GitHub Pages
- **Build target**: Flutter web with static hosting

## Deployment

The web app is automatically deployed to GitHub Pages via `.github/workflows/deploy-web.yml` when changes are pushed to the `develop` branch.

**URL**: [https://openfoodfacts.github.io/smooth-app/](https://openfoodfacts.github.io/smooth-app/)

## Development

To build locally:
```bash
cd packages/smooth_app
flutter build web --target=lib/entrypoints/web/main_web.dart --base-href="/smooth-app/"
```

## Future Enhancements

- Integration with ZXingJS for camera-based barcode scanning
- Improved responsive design for various screen sizes
- Progressive Web App (PWA) features
- Offline capabilities with service workers

## Limitations

- Manual barcode input only (camera scanning not yet implemented)
- Some mobile-specific features may not be available
- Performance may differ from native mobile apps