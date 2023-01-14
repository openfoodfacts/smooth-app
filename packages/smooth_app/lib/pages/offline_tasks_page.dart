import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_instant_string.dart';
import 'package:smooth_app/database/local_database.dart';

class OfflineTaskPage extends StatefulWidget {
  const OfflineTaskPage();

  @override
  State<OfflineTaskPage> createState() => _OfflineTaskState();
}

class _OfflineTaskState extends State<OfflineTaskPage> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoInstantString daoInstantString = DaoInstantString(localDatabase);
    final List<String> taskIds = localDatabase.getAllTaskIds();
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.background_task_title),
      ),
      body: taskIds.isEmpty
          ? Center(
              child: Text(appLocalizations.background_task_list_empty),
            )
          : ListView.builder(
              itemCount: taskIds.length,
              itemBuilder: (final BuildContext context, final int index) {
                final String taskId = taskIds[index];
                final String? status = daoInstantString.get(
                  BackgroundTaskManager.taskIdToErrorDaoInstantStringKey(
                    taskId,
                  ),
                );
                return ListTile(
                  title: Text(
                    '${OperationType.getBarcode(taskId)}'
                    ' (${_getOperationLabel(
                      OperationType.getOperationType(taskId),
                      appLocalizations,
                    )})',
                  ),
                  subtitle: Text(_getMessage(status, appLocalizations)),
                );
              },
            ),
    );
  }

  String _getOperationLabel(
    final OperationType? type,
    final AppLocalizations appLocalizations,
  ) {
    switch (type) {
      case null:
        return appLocalizations.background_task_operation_unknown;
      case OperationType.details:
        return appLocalizations.background_task_operation_details;
      case OperationType.image:
        return appLocalizations.background_task_operation_image;
      case OperationType.refreshLater:
        return appLocalizations.background_task_operation_refresh;
    }
  }

  String _getMessage(
    final String? status,
    final AppLocalizations appLocalizations,
  ) {
    switch (status) {
      case null:
        return appLocalizations.background_task_run_not_started;
      case BackgroundTaskManager.taskStatusStarted:
        return appLocalizations.background_task_run_started;
      case BackgroundTaskManager.taskStatusNoInternet:
        return appLocalizations.background_task_error_no_internet;
    }
    return status!;
  }
}
