import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/pages/prices/get_prices_model.dart';
import 'package:smooth_app/pages/prices/product_prices_list.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page that displays the latest prices according to a model.
class PricesPage extends StatelessWidget {
  const PricesPage(this.model);

  final GetPricesModel model;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return SmoothScaffold(
      appBar: SmoothAppBar(
        centerTitle: false,
        leading: const SmoothBackButton(),
        title: Text(
          model.title,
          maxLines: model.subtitle == null ? 2 : 1,
        ),
        subTitle: model.subtitle == null ? null : Text(model.subtitle!),
        actions: <Widget>[
          Semantics(
            link: true,
            label: appLocalizations.prices_app_button,
            excludeSemantics: true,
            child: IconButton(
              tooltip: appLocalizations.prices_app_button,
              icon: const ExcludeSemantics(child: Icon(Icons.open_in_new)),
              onPressed: () async => LaunchUrlHelper.launchURL(
                model.uri.toString(),
              ),
            ),
          ),
        ],
      ),
      body: ProductPricesList(model),
      floatingActionButton: model.addButton == null
          ? null
          : FloatingActionButton.extended(
              onPressed: model.addButton,
              label: Text(appLocalizations.prices_add_a_price),
              icon: const Icon(Icons.add),
            ),
    );
  }
}
