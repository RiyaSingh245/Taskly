import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/tasks.dart';

//creating StateFul Widget
class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;
  Box? _box;
  String? _newTaskcontent;
  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "Taskly!",
          style: TextStyle(
            fontSize: 25,
          ),
        ),
      ),
      body: _tasksview(),
      floatingActionButton: _addTasksButton(),
    );
  }

  Widget _tasksview() {
    //future Builder Widget
    return FutureBuilder(
      future: Hive.openBox('tasks'),
      builder: (BuildContext _context, AsyncSnapshot _snapshot) {
        if (_snapshot.hasData) {
          _box = _snapshot.data;
          return _tasksList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  // listview and lissTile Widgets
  Widget _tasksList() {
    List tasks = _box!.values.toList();
    //storing data in hive
    /*Task _newTask =
        Task(content: "Go To Gym!", timestamp: DateTime.now(), done: false);
    _box?.add(_newTask.toMap());*/

    //displaying tasks on listview
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext _context, int _index) {
        var task = Task.fromMap(tasks[_index]);
        return ListTile(
          title: Text(
            task.content,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            task.timestamp.toString(),
          ),
          trailing: Icon(
            task.done
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank_outlined,
            color: Colors.red,
          ),
          //updating
          onTap: () {
            task.done = !task.done;
            _box!.putAt(
              _index,
              task.toMap(),
            );
            setState(() {});
          },
          //deleting tasks
          onLongPress: () {
            _box!.deleteAt(_index);
            setState(() {});
          },
        );
      },
    );
  }

  //Floating action Button
  Widget _addTasksButton() {
    return FloatingActionButton(
      onPressed: _displayTaskPopup,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: const Text("Add New Task!"),
          //Textfield
          content: TextField(
            onSubmitted: (_) {
              //adding new tasks from UI
              if (_newTaskcontent != null) {
                var _task = Task(
                    content: _newTaskcontent!,
                    timestamp: DateTime.now(),
                    done: false);
                _box!.add(_task.toMap());
                setState(
                  () {
                    _newTaskcontent = null;
                    Navigator.pop(context);
                  },
                );
              }
            },
            onChanged: (_value) {
              //to re-render our UI and update the variable
              setState(
                () {
                  _newTaskcontent = _value;
                },
              );
            },
          ),
        );
      },
    );
  }
}
