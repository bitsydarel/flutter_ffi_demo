import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffi_demo/src/add_task_page.dart';
import 'package:flutter_ffi_demo/src/lmdb/lmdb.dart';
import 'package:flutter_ffi_demo/src/task.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as pp;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _databaseDirectory = pp.getApplicationSupportDirectory();
  LMDBEnvironment _environment;

  int taskId = 0;

  @override
  void dispose() {
    _environment?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_environment != null) {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => AddTaskPage(
                  environment: _environment,
                  taskId: "task$taskId",
                ),
              ),
            ).then((value) {
              if (value != null) {
                setState(() {});
              }
            });
          }
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: FutureBuilder(
          future: _databaseDirectory,
          builder: (_, AsyncSnapshot<Directory> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasData) {
                  if (_environment == null) {
                    _environment = LMDBEnvironment.open(
                      _getDBDir(snapshot.data),
                      10,
                    );
                  }

                  final tasks = _environment?.getAllTasks() ?? [];

                  taskId = tasks.length;

                  return ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      final task = tasks[index];
                      return _TaskWidget(task);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemCount: tasks.length,
                  );
                }

                return Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.headline4,
                );
              default:
                return CircularProgressIndicator();
            }
          },
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _TaskWidget extends StatelessWidget {
  final Task task;

  const _TaskWidget(this.task);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      trailing: Text(task.deadline.toIso8601String()),
    );
  }
}

String _getDBDir(Directory root) {
  final envFile = File(p.join(root.path, "demo_env"));
  envFile.createSync(recursive: true);
  assert(envFile.existsSync());
  return envFile.path;
}
