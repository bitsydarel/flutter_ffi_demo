import 'package:flutter/material.dart';
import 'package:flutter_ffi_demo/src/lmdb/lmdb.dart';
import 'package:flutter_ffi_demo/src/task.dart';

class AddTaskPage extends StatefulWidget {
  final LMDBEnvironment environment;

  final String taskId;

  const AddTaskPage({Key key, this.environment, this.taskId})
      : assert(environment != null),
        assert(taskId != null),
        super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _fieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _fieldController,
                  decoration: InputDecoration(
                    hintText: "Enter task name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (input) {
                    if (input?.isEmpty == true && input?.trim() == "") {
                      return "Task name can't be empty";
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate()) {
            final task = Task(
              widget.taskId,
              _fieldController.value.text,
              DateTime.now().add(Duration(days: 1)),
            );

            widget.environment.putTask(widget.taskId, task);

            final savedTask = widget.environment.getTask(widget.taskId);

            print("requested: $task \n saved: $savedTask");

            Navigator.of(context).pop(task);
          }
        },
        child: Icon(Icons.done),
      ),
    );
  }
}
