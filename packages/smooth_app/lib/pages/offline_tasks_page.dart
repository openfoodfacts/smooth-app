import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_manager.dart';
import 'package:smooth_app/data_models/operation_type.dart';
import 'package:smooth_app/database/dao_instant_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

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
                  onTap: () async {
                    final bool? stopTask = await showDialog<bool>(
                      context: context,
                      builder: (final BuildContext context) =>
                          SmoothAlertDialog(
                        body: Text(
                            appLocalizations.background_task_question_stop),
                        negativeAction: SmoothActionButton(
                          text: appLocalizations.no,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        positiveAction: SmoothActionButton(
                          text: appLocalizations.yes,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ),
                    );
                    if (stopTask == true) {
                      await BackgroundTaskManager(localDatabase)
                          .removeTaskAsap(taskId);
                    }
                  },
                  title: Text(
                    '${OperationType.getBarcode(taskId)}'
                    ' (${OperationType.getOperationType(taskId)?.getLabel(
                          appLocalizations,
                        ) ?? appLocalizations.background_task_operation_unknown})',
                  ),
                  subtitle: Text(_getMessage(status, appLocalizations)),
                  trailing: const Icon(Icons.clear),
                );
              },
            ),
    );
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
      case BackgroundTaskManager.taskStatusStopAsap:
        return appLocalizations.background_task_run_to_be_deleted;
    }
    return status!;
  }
}
