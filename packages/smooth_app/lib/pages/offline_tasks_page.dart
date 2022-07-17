import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/background_tasks_model.dart';
import 'package:smooth_app/database/dao_tasks.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:workmanager/workmanager.dart';

class OfflineTask extends StatefulWidget {
  const OfflineTask({Key? key}) : super(key: key);

  @override
  State<OfflineTask> createState() => _OfflineTaskState();
}

class _OfflineTaskState extends State<OfflineTask> {
  Future<List<BackgroundTaskModel>> _fetchListItems(
      DaoBackgroundTask daoBackgroundTask) async {
    final List<String> barcodes = await daoBackgroundTask.getAllKeys();
    final Map<String, BackgroundTaskModel> backgroundTaskModels =
        await daoBackgroundTask.getAll(barcodes);
    return backgroundTaskModels.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoBackgroundTask daoBackgroundTask =
        DaoBackgroundTask(localDatabase);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Background Tasks'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () async {
        //       for (int i = 0; i < 5; i++) {
        //         await daoBackgroundTask.put(
        //           BackgroundTaskModel(
        //               backgroundTaskId: SmoothRandom.generateRandomString(5),
        //               backgroundTaskName: 'ImageUpload',
        //               backgroundTaskDescription: 'backgroundTaskDescription',
        //               barcode: Random().nextInt(99999).toString(),
        //               dateTime: DateTime.now(),
        //               status: 'Done'),
        //         );
        //       }
        //       setState(() {});
        //     },
        //   ),
        // ],
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (int item) async {
              await Workmanager().cancelAll();
              const SnackBar snackBar = SnackBar(
                content: Text('All Tasks Cancelled'),
              );
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              const PopupMenuItem<int>(value: 0, child: Text('Cancel all')),
            ],
          ),
        ],
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: Center(
          child: FutureBuilder<List<BackgroundTaskModel>>(
            future: _fetchListItems(daoBackgroundTask),
            builder: (BuildContext context,
                AsyncSnapshot<List<BackgroundTaskModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('No Pending Tasks'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No data',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      );
                    }
                    return ListTile(
                      leading: getLeadingIcon(
                          context, snapshot.data![index].backgroundTaskName),
                      title: Text(
                        snapshot.data![index].barcode,
                      ),
                      subtitle: Text(snapshot.data![index].backgroundTaskName),
                      trailing: Wrap(
                        children: <Widget>[
                          IconButton(
                              // ignore: avoid_returning_null_for_void
                              onPressed: () => null,
                              icon: const Icon(Icons.refresh)),
                          IconButton(
                              onPressed: () async {
                                await Workmanager().cancelByUniqueName(
                                    snapshot.data![index].backgroundTaskId);
                                await daoBackgroundTask.delete(
                                  snapshot.data![index].backgroundTaskId,
                                );
                                setState(() {});
                              },
                              icon: const Icon(Icons.cancel))
                        ],
                      ),
                      onTap: () {},
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget getLeadingIcon(BuildContext context, String taskType) {
    switch (taskType) {
      case 'ImageUpload':
        return const Icon(Icons.image_sharp);
      case 'BasicInput':
        return const Icon(Icons.edit_note);
      // Default is here for nutrion edit tasks
      default:
        return const Icon(Icons.fastfood_outlined);
    }
  }
}
