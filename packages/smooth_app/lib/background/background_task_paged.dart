import 'package:smooth_app/background/background_task.dart';

/// Abstract background task with paged actions.
abstract class BackgroundTaskPaged extends BackgroundTask {
  const BackgroundTaskPaged({
    required super.processName,
    required super.uniqueId,
    required super.languageCode,
    required super.user,
    required super.country,
    required super.stamp,
    required this.pageSize,
  });

  BackgroundTaskPaged.fromJson(Map<String, dynamic> json)
      : pageSize = json[_jsonTagPageSize] as int,
        super.fromJson(json);

  final int pageSize;

  static const String _jsonTagPageSize = 'pageSize';

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = super.toJson();
    result[_jsonTagPageSize] = pageSize;
    return result;
  }
}
