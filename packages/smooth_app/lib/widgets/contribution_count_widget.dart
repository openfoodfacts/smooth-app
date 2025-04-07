// packages/smooth_app/lib/widgets/contribution_count_widget.dart

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContributionCountWidget extends StatefulWidget {
  const ContributionCountWidget({super.key});

  @override
  State<ContributionCountWidget> createState() =>
      _ContributionCountWidgetState();
}

class _ContributionCountWidgetState extends State<ContributionCountWidget> {
  int? _contributionCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContributions();
  }

  Future<void> _loadContributions() async {
    if (!ProductQuery.isLoggedIn()) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final User user = ProductQuery.getWriteUser();
      final Status status = await OpenFoodAPIClient.getStatus(user: user);

      if (mounted) {
        setState(() {
          _contributionCount =
              status.userId == user.userId ? status.contributionCount : 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ProductQuery.isLoggedIn()) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final ThemeData theme = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appLocalizations.your_contributions,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  _contributionCount?.toString() ?? '0',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
