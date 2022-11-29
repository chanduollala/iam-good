import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'tasksdb.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT,deadline TEXT,description TEXT, isCompleted BOOLEAN)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  runApp(const MyApp());
}

class Task {
  final int? id;
  final String title;
  final String? deadline;
  final String? description;
  final int isCompleted;

  const Task({
     this.id,
    required this.title,
     this.deadline,
     this.description,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline,
      'description': description,
      'isCompleted': isCompleted
    };
  }
}

Future<void> insertTask(Task task) async {
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'tasksdb.db'));
  await db.insert(
    'tasks',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> toggleCompletionStatus(int setTo,int id) async {
  // Get a reference to the database.
  final db = await openDatabase(join(await getDatabasesPath(), 'tasksdb.db'));
  await db.rawQuery('UPDATE tasks SET isCompleted=? WHERE id = ?',[setTo,id]);
}

Future<List<Task>> pendingTasks() async {
  // Get a reference to the database.
  final db =
      await openDatabase(join(await getDatabasesPath(), 'tasksdb.db'));
  ;

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps =
      await db.rawQuery('SELECT * FROM tasks WHERE tasks.isCompleted=? ORDER BY deadline IS NULL, deadline',[0]);

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        deadline: maps[i]['deadline'],
        description: maps[i]['description'],
        isCompleted: maps[i]['isCompleted']);
  });
}

Future<List<Task>> completedTasks() async {
  // Get a reference to the database.
  final db =
  await openDatabase(join(await getDatabasesPath(), 'tasksdb.db'));
  ;

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps =
  await db.rawQuery('SELECT * FROM tasks WHERE tasks.isCompleted=?',[1]);

  // Convert the List<Map<String, dynamic> into a List<Dog>.
  return List.generate(maps.length, (i) {
    return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        deadline: maps[i]['deadline'],
        description: maps[i]['description'],
        isCompleted: maps[i]['isCompleted']);
  });
}



Future<void> deleteTask(int id) async {
  // Get a reference to the database.
  final db =  await openDatabase(join(await getDatabasesPath(), 'tasksdb.db'));

  // Remove the Dog from the database.
  await db.delete(
    'tasks',
    // Use a `where` clause to delete a specific dog.
    where: 'id = ?',
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  var titleController= TextEditingController();
  var descriptionController = TextEditingController();
  var deadlineController = TextEditingController();


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<List<Task>> getPendingTasks() async {
    return await pendingTasks();
  }

  Future<List<Task>> getCompletedTasks() async {
    return await completedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Chandu's Task Manager"),
      ),
      body: SingleChildScrollView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Text(
                  "Pending Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              FutureBuilder<List<Task>>(
                  future:
                      getPendingTasks(), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Task>> snapshot) {
                    Widget child;
                    if (snapshot.hasData) {
                      child = ListView.builder(
                        shrinkWrap: true,
                        // Let the ListView know how many items it needs to build.
                        itemCount: snapshot.data!.length,
                        // Provide a builder function. This is where the magic happens.
                        // Convert each item into a widget based on the type of item it is.
                        prototypeItem: Card(
                          elevation: 30,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("k"),
                              ),
                              Spacer(),

                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.done_rounded)),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.delete))
                            ],
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];

                          return Card(
                            elevation: 30,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(snapshot.data![index].title),
                                ),
                                Spacer(),

                                IconButton(
                                    onPressed: () async{
                                      await toggleCompletionStatus(1, snapshot.data![index].id!);
                                      setState(()  {

                                      });
                                    },
                                    icon: Icon(Icons.done_rounded)),
                                IconButton(
                                    onPressed: () async{
                          await deleteTask(snapshot.data![index].id!);
                          setState(()  {

                          });
                          }
                          , icon: Icon(Icons.delete))
                              ],
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      child = Container(
                        height: 200,
                        child: Column(children: <Widget>[
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        ]),
                      );
                    } else {
                      child = Container(
                        height: 200,
                        child: Column(children: const <Widget>[
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Awaiting result...'),
                          ),
                        ]),
                      );
                    }
                    return child;
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Text(
                  "Completed Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              FutureBuilder<List<Task>>(
                  future:
                  getCompletedTasks(), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Task>> snapshot) {
                    Widget child;
                    if (snapshot.hasData) {
                      child = ListView.builder(
                        shrinkWrap: true,
                        // Let the ListView know how many items it needs to build.
                        itemCount: snapshot.data!.length,
                        // Provide a builder function. This is where the magic happens.
                        // Convert each item into a widget based on the type of item it is.
                        prototypeItem: Card(
                          elevation: 30,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("k"),
                              ),
                              Spacer(),

                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.done_rounded)),
                              IconButton(
                                  onPressed: () {}, icon: Icon(Icons.delete))
                            ],
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];

                          return Card(
                            elevation: 30,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(snapshot.data![index].title),
                                ),
                                Spacer(),

                                IconButton(
                                    onPressed: () async{
                                      await toggleCompletionStatus(0, snapshot.data![index].id!);
                                      setState(()  {

                                      });
                                    },
                                    icon: Icon(Icons.repeat)),
                                IconButton(
                                    onPressed: () async{
                                      await deleteTask(snapshot.data![index].id!);
                                      setState(()  {

                                      });
                                    }
                                    , icon: Icon(Icons.delete))
                              ],
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      child = Container(
                        height: 200,
                        child: Column(children: <Widget>[
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        ]),
                      );
                    } else {
                      child = Container(
                        height: 200,
                        child: Column(children: const <Widget>[
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Awaiting result...'),
                          ),
                        ]),
                      );
                    }
                    return child;
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          print("Hi");
          showModalBottomSheet(context: context, builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context1, StateSetter setSheetState){
            return Container(
              color: Colors.redAccent[100],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Add Task",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.normal
                          ),)
                        ],
                      ),

                      Card(
                        elevation: 30,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: 10 , top: 0, bottom: 5, right: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            label: Text("Title"),
                            hintText: "Enter title",
                            icon: Icon(Icons.abc)
                          ),
                          controller: titleController,
                        ),
                    ),
                      ),
                      Card(
                        elevation: 30,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: 10 , top: 0, bottom: 5, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextField(
                            maxLines: 4,
                            decoration: InputDecoration(
                                label: Text("Description"),
                                hintText: "Describe the task",
                              icon: Icon(Icons.description),
                            ),
                            controller: descriptionController,
                          ),
                        ),
                      ),
                      Card(
                        elevation: 30,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Container(
                          padding: EdgeInsets.only(left: 10 , top: 0, bottom: 5, right: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextField(
                            controller: deadlineController,
                            onTap: () async {
                              var date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2023, 12,03));
                              var time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: 23, minute: 59));
                              setSheetState(() {
                                if (date!=null && time!=null){
                                print("${date!.year}-${date!.month}-${date!.day} ${time!.hour}:${time!.minute}");
                                deadlineController.text = "${date!.year}-${date!.month}-${date!.day} ${time!.hour}:${time!.minute}";
                              }
                              });
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                                label: Text("Deadline"),
                              icon: Icon(Icons.timer)
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top:18.0),
                      child: Container(
                        width: MediaQuery.of(context1).size.width,
                        height: 50,padding: EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton.icon(onPressed: ()async {
if (titleController.value.text!=""){
                          var t1 = new Task(
                              id: null,
                              title: titleController.value.text,
                              deadline: (deadlineController.value.text =="")?null:deadlineController.value.text,
                              description: descriptionController.value.text,
                              isCompleted: 0);
                          await insertTask(t1);
                          for (var task in await pendingTasks()) {
                          print(task.toMap());
                          }
                          setState(() {

                          });
                          Navigator.pop(context1);
                          titleController.clear();
                          deadlineController.clear();
                          descriptionController.clear();

                        }}, label: Text("Add to pending tasks"),
                            icon: Icon(Icons.add),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          )),
                      ),
                    )
                    ]
                ),
              ),
            );
          }
          );});
          /*


           */
        },
        tooltip: 'Increment',
        label: Text("Add Task"),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
