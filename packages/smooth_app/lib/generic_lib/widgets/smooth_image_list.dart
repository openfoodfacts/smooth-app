import 'package:flutter/material.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_tile_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_list_view.dart';

/// Displays a list of [ProductImageData]
class SmoothImageList extends StatelessWidget {
  const SmoothImageList({
    required this.imagesData,
    this.onTap,
    this.loading = false,
  });

  final Map<ProductImageData, ImageProvider?> imagesData;
  final void Function(ProductImageData, ImageProvider?)? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<MapEntry<ProductImageData, ImageProvider?>> imageList =
        imagesData.entries.toList();
    final int count = imageList.length;

    return Scrollbar(
      child: SmoothListView.builder(
        loading: loading,
        itemCount: count,
        loadingWidget: (_, __) => SmoothListTileCard.loading(),
        itemBuilder: (_, int index) => SmoothListTileCard.image(
          imageProvider: imageList[index].value,
          title: Text(
            imageList[index].key.title,
            style: themeData.textTheme.headline4,
          ),
          onTap: onTap == null
              ? null
              : () => onTap!(imageList[index].key, imageList[index].value),
        ),
      ),
    );
  }
}
