import 'dart:async';

import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_create_edit_modal.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_empty_page.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_product_tag_extension.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_expandable_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class FolksonomyPage extends StatelessWidget {
  const FolksonomyPage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>(
      create: (BuildContext context) =>
          FolksonomyProvider(product.barcode!, context.read<LocalDatabase>()),
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ProductRefresher _productRefresher = ProductRefresher();
  final List<ProductTag> _tags = <ProductTag>[];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Consumer<FolksonomyProvider>(
      builder:
          (BuildContext context, FolksonomyProvider provider, Widget? child) {
            _onStateChanged(provider.value);
            return child!;
          },
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(appLocalizations.product_tags_title),
          subTitle: Text(
            getProductNameAndBrands(widget.product, appLocalizations),
          ),
        ),
        body: _buildBody(),
        floatingActionButton: SmoothExpandableFloatingActionButton(
          scrollController: _scrollController,
          onPressed: () async {
            if (!await _checkIfLoggedIn()) {
              return;
            }
            await _showEditDialog(
              action: FolksonomyAction.add,
              existingKeys: _tags.map((ProductTag tag) => tag.key).toList(),
            );
          },
          label: Text(appLocalizations.add_tag),
          icon: const icons.AddProperty.alt(),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    ProductTag entry,
    Animation<double> animation,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        onTap: entry.isAnUrl() ? () async => entry.visitUrl(context) : null,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: SMALL_SPACE,
            top: SMALL_SPACE,
            bottom: SMALL_SPACE,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: appLocalizations.tag_key_item,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' ${entry.key}'),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: appLocalizations.tag_value_item,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' ${entry.value}',
                      style: entry.isAnUrl()
                          ? const TextStyle(color: Colors.blue)
                          : null,
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        trailing: SmoothPopupMenuButton<FolksonomyAction>(
          buttonIcon: const Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) {
            return <SmoothPopupMenuItem<FolksonomyAction>>[
              if (entry.isAnUrl())
                SmoothPopupMenuItem<FolksonomyAction>(
                  label: appLocalizations.folksonomy_action_external_link_title,
                  value: FolksonomyAction.visitUrl,
                  icon: const icons.ExternalLink(),
                ),
              SmoothPopupMenuItem<FolksonomyAction>(
                label: appLocalizations.edit_tag,
                value: FolksonomyAction.edit,
                icon: const icons.Edit(),
              ),
              SmoothPopupMenuItem<FolksonomyAction>(
                label: appLocalizations.remove_tag,
                value: FolksonomyAction.remove,
                icon: const icons.Trash(),
              ),
            ];
          },
          onSelected: (FolksonomyAction value) async {
            if (value == FolksonomyAction.visitUrl) {
              await entry.visitUrl(context);
              return;
            }
            if (value == FolksonomyAction.edit) {
              if (!await _checkIfLoggedIn()) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              await _showEditDialog(
                action: value,
                existingKeys: _getExistingKeys(
                  context.read<FolksonomyProvider>(),
                ),
                key: entry.key,
                value: entry.value,
              );
            } else if (value == FolksonomyAction.remove) {
              if (!await _checkIfLoggedIn()) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              unawaited(
                context.read<FolksonomyProvider>().deleteTag(entry.key),
              );
            }
          },
        ),
      ),
    );
  }

  List<String> _getExistingKeys(FolksonomyProvider provider) {
    return _tags.map((ProductTag tag) => tag.key).toList(growable: false);
  }

  Future<void> _showEditDialog({
    required FolksonomyAction action,
    List<String>? existingKeys,
    String? key,
    String? value,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final FolksonomyProvider folksonomyProvider = context
        .read<FolksonomyProvider>();
    final FolksonomyTag? res = await showSmoothModalSheetForTextField(
      context: context,
      header: SmoothModalSheetHeader(
        title: appLocalizations.add_tag,
        prefix: const SmoothModalSheetHeaderPrefixIndicator(),
      ),
      bodyBuilder: (BuildContext context) {
        return ChangeNotifierProvider<FolksonomyProvider>.value(
          value: folksonomyProvider,
          child: FolksonomyEditTagContent(
            action: action,
            existingKeys: existingKeys,
            oldKey: key,
            oldValue: value,
          ),
        );
      },
    );

    if (res != null && mounted) {
      if (action == FolksonomyAction.edit) {
        unawaited(
          context.read<FolksonomyProvider>().editTag(res.key, res.value),
        );
      } else if (action == FolksonomyAction.add) {
        try {
          unawaited(
            context.read<FolksonomyProvider>().addTag(res.key, res.value),
          );
        } catch (e) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SmoothFloatingSnackbar.error(
              context: context,
              text: appLocalizations.tag_key_already_exists(res.key),
            ),
          );
        }
      }
    }
  }

  void _onStateChanged(FolksonomyState newState) {
    if (_listKey.currentState == null) {
      return;
    }

    if (newState is! FolksonomyStateLoaded) {
      if (_tags.isNotEmpty) {
        for (int i = _tags.length - 1; i >= 0; i--) {
          final ProductTag tag = _tags[i];
          _listKey.currentState?.removeItem(
            i,
            (BuildContext context, Animation<double> animation) =>
                _buildItem(context, tag, animation),
          );
        }
        _tags.clear();
      }
      return;
    }

    final List<ProductTag> newTags = newState.tags!;

    // Delete tags that are not in the new list.
    for (int i = _tags.length - 1; i >= 0; i--) {
      final ProductTag tag = _tags[i];
      if (!newTags.any((ProductTag newTag) => newTag.key == tag.key)) {
        _tags.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (BuildContext context, Animation<double> animation) =>
              _buildItem(context, tag, animation),
        );
      }
    }

    // Add tags that are new.
    for (int i = 0; i < newTags.length; i++) {
      final ProductTag tag = newTags[i];
      if (!_tags.any((ProductTag oldTag) => oldTag.key == tag.key)) {
        _tags.insert(i, tag);
        _listKey.currentState?.insertItem(i);
      }
    }

    // Edit tags that have changed.
    for (int i = 0; i < newTags.length; i++) {
      if (i < _tags.length &&
          newTags[i].key == _tags[i].key &&
          newTags[i].value != _tags[i].value) {
        _tags[i] = newTags[i];
      }
    }
  }

  Widget _buildBody() {
    final FolksonomyState state = context.watch<FolksonomyProvider>().value;

    if (state is FolksonomyStateLoaded && _tags.isEmpty) {
      _tags.addAll(state.tags!);
    }

    if (state is FolksonomyStateLoading && _tags.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    } else if (state is FolksonomyStateLoaded && state.tags!.isEmpty) {
      return const FolksonomyEmptyPage();
    } else if (state is FolksonomyStateError && state.action == null) {
      return const FolksonomyEmptyPage();
    }

    return AnimatedList.separated(
      key: _listKey,
      controller: _scrollController,
      initialItemCount: _tags.length,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
            final ProductTag entry = _tags[index];
            return _buildItem(context, entry, animation);
          },
      separatorBuilder: (_, _, Animation<double> animation) =>
          SizeTransition(sizeFactor: animation, child: const Divider()),
      removedSeparatorBuilder:
          (BuildContext context, int index, Animation<double> animation) =>
              SizeTransition(sizeFactor: animation, child: const Divider()),
    );
  }

  Future<bool> _checkIfLoggedIn() {
    return _productRefresher.checkIfLoggedIn(
      context,
      isLoggedInMandatory: true,
    );
  }
}
