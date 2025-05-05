import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_create_edit_modal.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_expandable_floating_action_button.dart';
import 'package:smooth_app/widgets/smooth_menu_button.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

class FolksonomyPage extends StatelessWidget {
  const FolksonomyPage({
    required this.product,
    required this.provider,
  });

  final Product product;
  final FolksonomyProvider provider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FolksonomyProvider>.value(
      value: provider,
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final FolksonomyProvider provider = context.watch<FolksonomyProvider>();

    return SmoothScaffold(
      appBar: SmoothTopBar2(
        title: appLocalizations.product_tags_title,
        leadingAction: SmoothLeadingAction.back,
      ),
      body: Listener<FolksonomyProvider>(
        listener: _onProviderChanged,
        child: Consumer<FolksonomyProvider>(
          builder: (BuildContext context, FolksonomyProvider provider, _) {
            if (provider.value is FolksonomyStateLoading ||
                provider.value is FolksonomyStateError &&
                    (provider.value as FolksonomyStateError).action == null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return AnimatedList.separated(
              key: _listKey,
              controller: _scrollController,
              initialItemCount: provider.value.tags!.length,
              itemBuilder: (
                BuildContext context,
                int index,
                Animation<double> animation,
              ) {
                final ProductTag entry = provider.value.tags![index];

                return _buildItem(
                  context,
                  entry,
                  animation,
                  provider.isAuthorized,
                );
              },
              separatorBuilder: (_, __, Animation<double> animation) =>
                  SizeTransition(
                sizeFactor: animation,
                child: const Divider(),
              ),
              removedSeparatorBuilder: (
                BuildContext context,
                int index,
                Animation<double> animation,
              ) =>
                  SizeTransition(
                sizeFactor: animation,
                child: const Divider(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: provider.isAuthorized
          ? SmoothExpandableFloatingActionButton(
              scrollController: _scrollController,
              onPressed: () async => _showEditDialog(
                action: FolksonomyAction.add,
                existingKeys: _getExistingKeys(provider),
              ),
              label: Text(appLocalizations.add_tag),
              icon: const icons.AddProperty.alt(),
            )
          : EMPTY_WIDGET,
    );
  }

  Widget _buildItem(
    BuildContext context,
    ProductTag entry,
    Animation<double> animation,
    bool isAuthorized,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
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
                    TextSpan(
                      text: ' ${entry.key}',
                    ),
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
                    ),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        trailing: isAuthorized
            ? SmoothPopupMenuButton<FolksonomyAction>(
                buttonIcon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) {
                  return <SmoothPopupMenuItem<FolksonomyAction>>[
                    SmoothPopupMenuItem<FolksonomyAction>(
                      label: appLocalizations.edit_tag,
                      value: FolksonomyAction.edit,
                      icon: Icons.edit,
                    ),
                    SmoothPopupMenuItem<FolksonomyAction>(
                      label: appLocalizations.remove_tag,
                      value: FolksonomyAction.remove,
                      icon: Icons.delete,
                    ),
                  ];
                },
                onSelected: (FolksonomyAction value) {
                  if (value == FolksonomyAction.edit) {
                    _showEditDialog(
                      action: value,
                      existingKeys: _getExistingKeys(
                        context.read<FolksonomyProvider>(),
                      ),
                      key: entry.key,
                      value: entry.value,
                    );
                  } else if (value == FolksonomyAction.remove) {
                    context.read<FolksonomyProvider>().deleteTag(entry.key);
                  }
                },
              )
            : null,
      ),
    );
  }

  List<String> _getExistingKeys(FolksonomyProvider provider) {
    return provider.value.tags!
        .map((ProductTag tag) => tag.key)
        .toList(growable: false);
  }

  Future<void> _showEditDialog({
    required FolksonomyAction action,
    List<String>? existingKeys,
    String? key,
    String? value,
  }) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final FolksonomyTag? res = await showSmoothModalSheetForTextField(
      context: context,
      header: SmoothModalSheetHeader(
        title: appLocalizations.add_tag,
        prefix: const SmoothModalSheetHeaderPrefixIndicator(),
      ),
      bodyBuilder: (BuildContext context) {
        return FolksonomyEditTagContent(
          action: action,
          existingKeys: existingKeys,
          oldKey: key,
          oldValue: value,
        );
      },
    );

    if (res != null && mounted) {
      if (action == FolksonomyAction.edit) {
        context.read<FolksonomyProvider>().editTag(
              res.key,
              res.value,
            );
      } else if (action == FolksonomyAction.add) {
        try {
          context.read<FolksonomyProvider>().addTag(
                res.key,
                res.value,
              );
        } catch (e) {
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

  void _onProviderChanged(
    BuildContext context,
    _,
    FolksonomyProvider provider,
  ) {
    if (provider.value is FolksonomyStateAddedItem) {
      final FolksonomyStateAddedItem state =
          provider.value as FolksonomyStateAddedItem;
      _listKey.currentState!.insertItem(state.addedPosition);

      onNextFrame(() => provider.markAsConsumed());
    } else if (provider.value is FolksonomyStateRemovedItem) {
      final FolksonomyStateRemovedItem state =
          provider.value as FolksonomyStateRemovedItem;
      _listKey.currentState!.removeItem(
        state.removedPosition,
        (BuildContext context, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: _buildItem(
              context,
              state.item,
              animation,
              provider.isAuthorized,
            ),
          );
        },
      );

      onNextFrame(() => provider.markAsConsumed());
    }
  }
}
