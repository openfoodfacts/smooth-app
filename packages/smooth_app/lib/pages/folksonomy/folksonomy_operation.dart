import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';

class FolksonomyOperation {
  FolksonomyOperation({
    required this.type,
    required this.tag,
    this.isPerformed = false,
  });

  final FolksonomyAction type;
  final ProductTag tag;
  bool isPerformed;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.name,
    'tag': tag.toJson(),
    'isPerformed': isPerformed,
  };

  static FolksonomyOperation fromJson(Map<String, dynamic> json) =>
      FolksonomyOperation(
        type: FolksonomyAction.values.byName(json['type'] as String),
        tag: ProductTag.fromJson(json['tag'] as Map<String, dynamic>),
        isPerformed: json['isPerformed'] as bool,
      );
}
