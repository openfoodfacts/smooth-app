import 'package:flutter/material.dart';
import 'package:task_manager/task_manager.dart';

// TODO(ashaman999): add the translations later
class OfflineTask extends StatefulWidget {
  const OfflineTask({
    super.key,
  });

  @override
  State<OfflineTask> createState() => _OfflineTaskState();
}

class _OfflineTaskState extends State<OfflineTask> {
  Future<List<Task>> _fetchListItems() async {
    final Iterable<Task> tasks = await TaskManager().listPendingTasks();
    return tasks.toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Background Tasks'),
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (int item) async {
              await _cancelAllTask();
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
                  child: CircularProgressIndicator.adaptive(),
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
                    return _getListTileItem(
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

  Widget _getListTileItem(
    int index,
    String uniqueId,
    String processName,
    String barcode,
  ) {
    return ListTile(
      leading: Text(index.toString()),
      title: Text(barcode),
      subtitle: Text(processName),
      trailing: Wrap(
        children: <Widget>[
          IconButton(
              onPressed: () async {
                String status = 'Retrying';
                try {
                  TaskManager().runTask(uniqueId);
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
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
          IconButton(
              onPressed: () async {
                await _cancelTask(uniqueId);

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
        duration: Duration(seconds: 3),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text('Error: $e'),
        duration: const Duration(seconds: 3),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _cancelAllTask() async {
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
  }
}
