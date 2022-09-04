import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:task_manager/task_manager.dart';

// TODO(ashaman999): add the translations later
const int POPUP_MENU_FIRST_ITEM = 0;

class OfflineTaskPage extends StatefulWidget {
  const OfflineTaskPage({
    super.key,
  });

  @override
  State<OfflineTaskPage> createState() => _OfflineTaskState();
}

class _OfflineTaskState extends State<OfflineTaskPage> {
  Future<List<Task>> _fetchListItems() async {
    return TaskManager().listPendingTasks().then(
          (Iterable<Task> value) => value.toList(
            growable: false,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Background Tasks'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (_) async {
              await _cancelAllTask();
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              const PopupMenuItem<int>(
                  value: POPUP_MENU_FIRST_ITEM, child: Text('Cancel all')),
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
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.data!.isEmpty) {
                return const EmptyScreen();
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
                    return TaskListTile(
                      index,
                      snapshot.data![index].uniqueId,
                      snapshot.data![index].data!['processName'].toString(),
                      snapshot.data![index].data!['barcode'].toString(),
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

  Future<void> _cancelAllTask() async {
    String status = 'All tasks Cancelled';
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
      duration: SnackBarDuration.medium,
    );
    setState(() {});
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class TaskListTile extends StatefulWidget {
  const TaskListTile(
    this.index,
    this.uniqueId,
    this.processName,
    this.barcode,
  )   : assert(index >= 0),
        assert(uniqueId.length > 0),
        assert(barcode.length > 0),
        assert(processName.length > 0);

  final int index;
  final String uniqueId;
  final String processName;
  final String barcode;

  @override
  State<TaskListTile> createState() => _TaskListTileState();
}

class _TaskListTileState extends State<TaskListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text((widget.index + 1).toString()),
      title: Text(widget.barcode),
      subtitle: Text(widget.processName),
      trailing: Wrap(
        children: <Widget>[
          IconButton(
              onPressed: () {
                String status = 'Retrying';
                try {
                  TaskManager().runTask(widget.uniqueId);
                } catch (e) {
                  status = 'Error: $e';
                }
                final SnackBar snackBar = SnackBar(
                  content: Text(status),
                  duration: SnackBarDuration.medium,
                );
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () async {
                await _cancelTask(widget.uniqueId);

                setState(() {});
              },
              icon: const Icon(Icons.cancel))
        ],
      ),
    );
  }

  Future<void> _cancelTask(String uniqueId) async {
    try {
      await TaskManager().cancelTask(uniqueId);
      const SnackBar snackBar = SnackBar(
        content: Text('Cancelled'),
        duration: SnackBarDuration.medium,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text('Error: $e'),
        duration: SnackBarDuration.medium,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No Pending Tasks'));
  }
}
