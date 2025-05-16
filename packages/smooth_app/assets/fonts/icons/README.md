# App icons

![List of icons](thumbnail.png)


We don't use icons from SVG, but from a font.

Font icons are way more efficient for multiple reasons:
- There is a tree-shaking process that removes unused icons on release builds 
- When we want to apply a shadow, a text (= icon from font) is way more efficient than an SVG

## How to generate the font?

1. Go to https://www.fluttericon.com/
2. Click on `Import` and select `config.json`
3. Please ensure to only have **squared** icons
4. If you have a red warning BUT the visual is OK, you can ignore it
5. Once your changes are OK, download the archive
6. Place the font in `assets/fonts/`
7. Update `config.json` with the new version of the font
8. Update `lib/resources/app_icons_font.dart`
9. Create new Widgets for each icon in `lib/resources/app_icons.dart`