import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyOperation {
  FolksonomyOperation({required this.type, required this.tag});

  final FolksonomyAction type;
  final ProductTag tag;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'tag': tag.toJson(),
  };

  static FolksonomyOperation fromJson(Map<String, dynamic> json) =>
      FolksonomyOperation(
        type: FolksonomyAction.values.byName(json['type'] as String),
        tag: ProductTag.fromJson(json['tag'] as Map<String, dynamic>),
      );
}
