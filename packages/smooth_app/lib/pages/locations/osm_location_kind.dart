import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:smooth_app/pages/locations/osm_location.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// What an [OsmLocation] is, from its OSM tag ([OsmLocation.osmKey] and
/// [OsmLocation.osmValue]), e.g. `shop=supermarket`.
///
/// [OsmLocation.osmType] cannot be used: it is the kind of OSM element (node,
/// way or relation), not the kind of place.
enum OsmLocationKind {
  supermarket(<String>['shop:supermarket', 'shop:wholesale']),
  convenience(<String>['shop:convenience', 'shop:general', 'shop:kiosk']),
  mall(<String>['shop:mall', 'shop:department_store']),
  bakery(<String>['shop:bakery', 'shop:pastry', 'shop:confectionery']),
  butcher(<String>['shop:butcher']),
  seafood(<String>['shop:seafood']),
  greengrocer(<String>['shop:greengrocer']),
  dairy(<String>['shop:dairy', 'shop:cheese']),
  organic(<String>['shop:organic', 'shop:health_food']),
  farm(<String>['shop:farm']),
  gardenCentre(<String>['shop:garden_centre']),
  restaurant(<String>['amenity:restaurant', 'amenity:fast_food']),

  /// Any other shop.
  shop(<String>['shop']),
  place(<String>['place']),
  street(<String>['highway']),
  unknown(<String>[]);

  const OsmLocationKind(this._tags);

  /// Either `key:value`, or `key` alone to match any value.
  final List<String> _tags;

  static OsmLocationKind of(OsmLocation location) {
    final String? key = location.osmKey;
    if (key == null) {
      return unknown;
    }

    final String tag = '$key:${location.osmValue}';
    return values.firstWhereOrNull(
          (OsmLocationKind kind) => kind._tags.contains(tag),
        ) ??
        values.firstWhereOrNull(
          (OsmLocationKind kind) => kind._tags.contains(key),
        ) ??
        unknown;
  }

  Widget get icon => switch (this) {
    .supermarket => const icons.Shopping.cart(),
    .convenience => const icons.Shopping.bag(),
    .mall => const icons.Stores(),
    .bakery => const icons.Cupcake(),
    .butcher => const icons.Chicken(),
    .seafood => const icons.Fish(),
    .greengrocer => const icons.Fruit(),
    .dairy => const icons.Milk(),
    .organic => const icons.Plant(),
    .farm => const icons.Farmer(),
    .gardenCentre => const icons.Garden(),
    .restaurant => const icons.Chef(),
    .shop => const icons.Shop(),
    .place => const icons.City(),
    .street => const icons.Street(),
    .unknown => const icons.Shop(),
  };
}
