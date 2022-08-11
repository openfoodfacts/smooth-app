import 'package:flutter/material.dart';
import 'package:task_manager/task_manager.dart';

// TODO(ashaman999): add the translations later
class OfflineTask extends StatefulWidget {
  const OfflineTask({Key? key}) : super(key: key);

  @override
  State<OfflineTask> createState() => _OfflineTaskState();
}

class _OfflineTaskState extends State<OfflineTask> {
  Future<List<Task>> _fetchListItems() async {
    final Iterable<Task> tasks = await TaskManager().listPendingTasks();
    return tasks.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Background Tasks'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (int item) async {
              String status = 'All tasks Caneclled';
              try {
                await TaskManager().cancelTasks();
              } catch (e) {
                status = 'Something went wrong';
              }
              setState(() {});
              final SnackBar snackBar = SnackBar(
                content: Text(
                  status,
                ),
                duration: const Duration(seconds: 3),
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
          child: FutureBuilder<List<Task>>(
            future: _fetchListItems(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
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
                        context,
                        snapshot.data![index].uniqueId,
                      ),
                      title: Text(
                        snapshot.data![index].data!['barcode'].toString(),
                      ),
                      subtitle: Text(snapshot.data![index].data!['processName']
                          .toString()),
                      trailing: Wrap(
                        children: <Widget>[
                          IconButton(
                              onPressed: () async {
                                String status = 'Retrying';
                                try {
                                  TaskManager()
                                      .runTask(snapshot.data![index].uniqueId);
                                } catch (e) {
                                  status = 'Error: $e';
                                }
                                final SnackBar snackBar = SnackBar(
                                  content: Text(status),
                                  duration: const Duration(seconds: 3),
                                );
                                if (!mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh)),
                          IconButton(
                              onPressed: () async {
                                String status = 'Cancelled';
                                try {
                                  await TaskManager().cancelTask(
                                      snapshot.data![index].uniqueId);
                                } catch (e) {
                                  status = 'Error: $e';
                                }
                                final SnackBar snackBar = SnackBar(
                                  content: Text(status),
                                  duration: const Duration(seconds: 3),
                                );
                                if (!mounted) {
                                  return;
                                }
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                setState(() {});
                              },
                              icon: const Icon(Icons.cancel))
                        ],
                      ),
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
        return const Icon(Icons.photo);
      case 'BasicInput':
        return const Icon(Icons.edit_outlined);
      case 'NutrientEdit':
        return const Icon(Icons.fastfood);
      default:
        return const Icon(Icons.edit);
    }
  }
}
