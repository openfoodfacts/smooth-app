import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_create_edit_modal.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyPage extends StatelessWidget {
  const FolksonomyPage(this.product);
  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (_) => FolksonomyProvider(product.barcode!),
      child: _FolksonomyContent(product),
    );
  }
}

class _FolksonomyContent extends StatefulWidget {
  const _FolksonomyContent(this.product);
  final Product product;

  @override
  _FolksonomyContentState createState() => _FolksonomyContentState();
}

class _FolksonomyContentState extends State<_FolksonomyContent> {
  void _showBottomSheet(BuildContext context, AppLocalizations appLocalizations,
      FolksonomyProvider provider,
      {required String key, required String value, String? comment}) {
    showSmoothModalSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(appLocalizations.edit_tag),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FolksonomyCreateEditModal(
                      provider: provider,
                      oldKey: key,
                      oldValue: value,
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(appLocalizations.remove_tag),
              onTap: () async {
                Navigator.pop(context);
                await provider.deleteTag(key);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final FolksonomyProvider provider = context.watch<FolksonomyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.product_tags_title),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.productTags!.length,
              itemBuilder: (BuildContext context, int index) {
                final MapEntry<String, ProductTag> entry =
                    provider.productTags!.entries.elementAt(index);
                return ListTile(
                  title: Text(
                    '${entry.key} : ${entry.value.value}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: provider.isAuthorized
                      ? IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            _showBottomSheet(
                                context, appLocalizations, provider,
                                key: entry.key,
                                value: entry.value.value,
                                comment: entry.value.comment);
                          },
                        )
                      : null,
                );
              },
            ),
      floatingActionButton: provider.isAuthorized
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FolksonomyCreateEditModal(
                      provider: provider,
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : EMPTY_WIDGET,
    );
  }
}
