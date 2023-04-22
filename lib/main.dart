import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('todo_Box');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyTodo(),
  ));
}

class MyTodo extends StatefulWidget {
  @override
  State<MyTodo> createState() => _MyTodoState();
}

class _MyTodoState extends State<MyTodo> {
  List<Map<String, dynamic>> Maintasks = [];
  final title = TextEditingController();
  final itemtask = TextEditingController();
 
  final mytaskbox = Hive.box("todo_box");

  Future<void> createtodo(Map<String, dynamic> newtask) async {
    await mytaskbox.add(newtask);
    fetchTask();
  }

  void fetchTask() {
    //read all data from hive
    final Tasksfromhive = mytaskbox.keys.map((key) {
      final value = mytaskbox.get(key);
      return {"id": key, "title": value['title'], 'task': value['task']};
    }).toList();

    setState(() {
      Maintasks = Tasksfromhive.reversed.toList();
    });
  }

  Map<String, dynamic> readData(int key) {
    final setData = mytaskbox.get(key);
    return setData;
  }

  Future<void> deleteTask(int itemkey) async {
    await mytaskbox.delete(itemkey);
    fetchTask();
  }

  void taskshow(BuildContext context, int? keyvalue) {
    if (keyvalue != null) {
      final existing_task =
      Maintasks.firstWhere((element) => element['id'] == keyvalue);
      title.text = existing_task['title'];
      itemtask.text = existing_task['task'];
    }
    void updateTask(int itemkey, Map<String, String> update) async {
      await mytaskbox.put(itemkey, update); //update task
      fetchTask();
    }

    showModalBottomSheet(
        backgroundColor: Colors.white54,
        isScrollControlled: true,
        elevation: 5,
        context: context,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20),
            child: Column(
              children: [
                TextField(
                  controller: title,
                  decoration: InputDecoration(hintText: 'title'),
                ),
                TextField(
                  controller: itemtask,
                  decoration: InputDecoration(hintText: 'Discription'),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (keyvalue == null) {
                        createtodo({
                          'title': title.text.trim(),
                          'task': itemtask.text.trim()
                        });
                      }
                      if (keyvalue != null) {
                        updateTask(keyvalue,
                            {'title': title.text, 'task': itemtask.text});
                      }
                      title.text = '';
                      itemtask.text = "";
                      Navigator.of(context).pop();
                    },
                    child:
                    Text(keyvalue == null ? 'Create task ' : 'update task'))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white54,
        floatingActionButton: FloatingActionButton(
          onPressed: () => taskshow(context, null),
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left:70),
            child: Text("My Todo"),
          ),
          backgroundColor: Colors.brown,
        ),
        body: Maintasks.isEmpty
            ? Center(child: Text("Empty Task"))
            : ListView.builder(
            itemCount: Maintasks.length,
            itemBuilder: (ctx, index) {
              final mytask = Maintasks[index];
              return Card(
                color: Colors.transparent,
                child: ListTile(
                  title: Text(mytask['title']),
                  subtitle: Text(mytask['task']),
                  trailing: Wrap(
                    children: [
                      IconButton(
                          onPressed: () {
                            taskshow(context, mytask['id']);
                          },
                          icon: Icon(Icons.edit)),
                      IconButton(
                          onPressed: () {
                            deleteTask(mytask['id']);
                          },
                          icon: Icon(Icons.delete))
                    ],
                  ),
                ),
              );
            }));
  }
}
