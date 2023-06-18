import 'package:smooth_app/background/background_task_paged.dart';

/// Abstract background task with work in progress actions.
abstract class BackgroundTaskProgressing extends BackgroundTaskPaged {
  const BackgroundTaskProgressing({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required super.pageSize,
    required this.work,
    required this.totalSize,
  });

  BackgroundTaskProgressing.fromJson(Map<String, dynamic> json)
      : work = json[_jsonTagWork] as String,
        totalSize = json[_jsonTagTotalSize] as int,
        super.fromJson(json);

  final String work;
  final int totalSize;

  static const String _jsonTagWork = 'work';
  static const String _jsonTagTotalSize = 'totalSize';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagWork] = work;
    result[_jsonTagTotalSize] = totalSize;
    return result;
  }

  static const String noBarcode = 'NO_BARCODE';

  /// Work about downloading top products.
  static const String workOffline = 'O';

  /// Work about downloading fresh products with Knowledge Panels.
  static const String workFreshWithKP = 'K';

  /// Work about downloading fresh products without KP.
  static const String workFreshWithoutKP = 'w';
}
