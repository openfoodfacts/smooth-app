import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/location_list_supplier.dart';
import 'package:smooth_app/data_models/location_query_model.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_error_card.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/locations/search_location_preloaded_item.dart';
import 'package:smooth_app/pages/product/common/loading_status.dart';
import 'package:smooth_app/pages/product/common/search_app_bar_title.dart';
import 'package:smooth_app/pages/product/common/search_empty_screen.dart';
import 'package:smooth_app/pages/product/common/search_loading_screen.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays location results during and after download.
class LocationQueryPage extends StatefulWidget {
  const LocationQueryPage({
    required this.query,
    required this.editableAppBarTitle,
  });

  final String query;
  final bool editableAppBarTitle;

  @override
  State<LocationQueryPage> createState() => _LocationQueryPageState();
}

class _LocationQueryPageState extends State<LocationQueryPage>
    with TraceableClientMixin {
  late LocationQueryModel _model;

  @override
  String get actionName => 'Opened location_search_page';

  @override
  void initState() {
    super.initState();
    _model = LocationQueryModel(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final ThemeData themeData = Theme.of(context);

    return ChangeNotifierProvider<LocationQueryModel>.value(
      value: _model,
      builder: (BuildContext context, _) {
        context.watch<LocationQueryModel>();

        switch (_model.loadingStatus) {
          case LoadingStatus.ERROR:
            return _getErrorWidget(
              screenSize,
              themeData,
              _model.loadingError ?? '',
            );
          case LoadingStatus.LOADING:
            if (_model.isEmpty()) {
              return SearchLoadingScreen(title: widget.query);
            }
            break;
          case LoadingStatus.LOADED:
            if (_model.isEmpty() && _model.alternateSupplier == null) {
              return SearchEmptyScreen(
                name: widget.query,
                emptiness: _getEmptyText(
                  themeData,
                  appLocalizations.no_location_found,
                ),
              );
            }
            break;
        }
        // Now used in two cases.
        // 1. we have data downloaded and we display it (normal mode)
        // 2. we are downloading extra data, and display what we already knew
        return _getNotEmptyScreen(screenSize, themeData, appLocalizations);
      },
    );
  }

  Widget _getNotEmptyScreen(
    final Size screenSize,
    final ThemeData themeData,
    final AppLocalizations appLocalizations,
  ) => SmoothScaffold(
    appBar: SmoothAppBar(
      backgroundColor: themeData.scaffoldBackgroundColor,
      elevation: 2,
      automaticallyImplyLeading: false,
      leading: const SmoothBackButton(),
      title: SearchAppBarTitle(
        title: widget.query,
        editableAppBarTitle: widget.editableAppBarTitle,
      ),
    ),
    body: ListTileTheme(
      data: ListTileThemeData(
        titleTextStyle: const TextStyle(fontSize: 20.0),
        minLeadingWidth: 18.0,
        iconColor: Theme.of(context).colorScheme.onSurface,
        textColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index >= _model.displayedResults.length) {
            final LocationListSupplier? supplier = _model.alternateSupplier;
            if (supplier != null) {
              return SmoothCard(
                child: SmoothLargeButtonWithIcon(
                  text: appLocalizations.prices_location_search_broader,
                  leadingIcon: const Icon(Icons.search),
                  onPressed: () => unawaited(_model.loadMore(supplier)),
                ),
              );
            }
            return const Padding(
              padding: EdgeInsets.only(top: SMALL_SPACE),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          return KeyedSubtree(
            key: ValueKey<int>(_model.displayedResults[index].osmId),
            child: SearchLocationPreloadedItem(
              _model.displayedResults[index],
              popFirst: true,
            ).getWidget(context),
          );
        },
        itemCount:
            _model.displayedResults.length +
            (_model.alternateSupplier != null
                ? 1
                : _model.loadingStatus == LoadingStatus.LOADING
                ? 1
                : 0),
      ),
    ),
  );

  Widget _getErrorWidget(
    final Size screenSize,
    final ThemeData themeData,
    final String errorMessage,
  ) {
    return SearchEmptyScreen(
      name: widget.query,
      emptiness: Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: SmoothErrorCard(
          errorMessage: errorMessage,
          tryAgainFunction: retryConnection,
        ),
      ),
    );
  }

  Widget _getEmptyText(final ThemeData themeData, final String message) =>
      Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: themeData.textTheme.titleMedium!.copyWith(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      );

  void retryConnection() {
    if (mounted) {
      setState(() => _model = LocationQueryModel(widget.query));
    }
  }
}
