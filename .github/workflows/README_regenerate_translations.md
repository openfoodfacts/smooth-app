# Translation File Regeneration Workflow

This document explains the automated translation file regeneration workflow that was added to address issue #6892.

## Overview

The workflow `regenerate-translations.yml` automatically regenerates Flutter translation files when ARB (Application Resource Bundle) files are modified. This eliminates the manual step developers previously needed to perform when adding new translation strings.

## How It Works

### Triggers
1. **Automatic**: When ARB files in `packages/smooth_app/lib/l10n/*.arb` are pushed to the `develop` branch
2. **Manual**: Via the "Actions" tab using the "workflow_dispatch" trigger

### Process
1. **Environment Setup**: Uses the Flutter version specified in `flutter-version.txt` (currently 3.35.1)
2. **Dependencies**: Installs Flutter dependencies for the smooth_app package
3. **Tool Installation**: Installs `intl_utils` globally using `flutter pub global activate intl_utils`
4. **Generation**: Runs `flutter pub global run intl_utils:generate` to create updated translation files
5. **Change Detection**: Checks if any files were modified during generation
6. **PR Creation**: If changes are detected, creates an automated PR with the updates

### Generated Files
The workflow updates these files when needed:
- `packages/smooth_app/lib/l10n/app_localizations.dart` (main localization class)
- `packages/smooth_app/lib/l10n/app_localizations_*.dart` (language-specific implementations)

## Testing the Workflow

### Prerequisites
To test this workflow:
1. The workflow file must be in the `develop` branch
2. You need write permissions to the repository
3. GitHub Actions must be enabled

### Test Scenarios

#### Scenario 1: Modify an ARB file
1. Edit `packages/smooth_app/lib/l10n/app_en.arb` to add a new translation string:
   ```json
   "test_string": "This is a test string",
   "@test_string": {
     "description": "A test string for workflow validation"
   }
   ```
2. Commit and push to the `develop` branch
3. Check the "Actions" tab to see the workflow run
4. If successful, a PR should be created with regenerated files

#### Scenario 2: Manual trigger
1. Go to Actions → "🌐 Regenerate Translation Files"
2. Click "Run workflow" 
3. Select the `develop` branch
4. Click "Run workflow"
5. Monitor the execution and check for PR creation

### Expected Results
- **No Changes**: If no ARB files were modified since the last generation, the workflow should complete without creating a PR
- **With Changes**: If ARB files contain new/modified strings, the workflow should:
  - Successfully regenerate the Dart files
  - Create a PR with clear description
  - Apply appropriate labels (`🌐 l10n`, `🤖 automated pr`)
  - Assign the PR to the triggering user

### Troubleshooting

#### Common Issues
1. **Flutter Version Mismatch**: Ensure `flutter-version.txt` contains a valid Flutter version
2. **Permission Errors**: Check that the workflow has `contents: write` and `pull-requests: write` permissions
3. **Dependency Issues**: Verify that `packages/smooth_app/pubspec.yaml` is valid

#### Debug Steps
1. Check the workflow logs in the Actions tab
2. Look for error messages in the "Generate translation files" step
3. Verify that ARB files are syntactically correct JSON
4. Ensure the l10n configuration in `packages/smooth_app/l10n.yaml` is correct

## Workflow Configuration

The workflow is configured to:
- Use caching for Flutter SDK and dependencies
- Run only when ARB files change (efficient)
- Cancel previous runs if new ones are triggered (saves resources)
- Create unique branch names to avoid conflicts
- Provide detailed PR descriptions for easy review

## Integration with Existing Workflows

This workflow complements the existing Crowdin workflow (`crowdin.yml`) which handles:
- Uploading source strings to Crowdin
- Downloading translated strings from Crowdin
- Creating PRs with Crowdin translations

The translation regeneration workflow specifically handles the Flutter code generation step that must occur after ARB file changes.