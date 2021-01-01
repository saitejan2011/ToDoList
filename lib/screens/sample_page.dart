import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ToDoList/models/to_do_model.dart';
import 'package:ToDoList/screens/to_do_form.dart';
import 'package:ToDoList/utilities/db_helper.dart';

class SamplePage extends StatefulWidget {
  @override
  _SamplePageState createState() => _SamplePageState();
}

class _SamplePageState extends State<SamplePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<ToDo> _toDoList = null;
  List _tabs;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (_toDoList == null) {
      _toDoList = new List<ToDo>();
      udpateListView();
    }

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: MediaQuery.of(context).size.height * 0.2,
                title: Center(child: Text('To Do List')),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.none,
                  background: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                          Colors.blue,
                          Colors.lime,
                        ])),
                  ),
                ),
              ),
              SliverPadding(
                padding: new EdgeInsets.all(16.0),
                sliver: new SliverList(
                  delegate: new SliverChildListDelegate([
                    TabBar(
                        labelColor: Colors.black87,
                        unselectedLabelColor: Colors.grey,
                        onTap: (val) {
                          print(val);
                        },
                        tabs: [
                          Tab(icon: Icon(Icons.home), text: "All"),
                          Tab(
                            key: UniqueKey(),
                            icon: Icon(Icons.pending),
                            text: "Pending",
                          ),
                          Tab(
                            key: UniqueKey(),
                            icon: Icon(Icons.done_all),
                            text: "Completed",
                          ),
                        ]),
                  ]),
                ),
              ),
            ];
          },
          body: Container(
            child: ListView.builder(
                itemCount: count,
                itemBuilder: (context, index) {
                  ToDo toDoObj = _toDoList[index];
                  bool isCompleted =
                      toDoObj.status.toLowerCase() == "completed";
                  return Container(
                      child: Card(
                          shape: isTaskCompleted(isCompleted),
                          child: GestureDetector(
                            onTap: () {
                              navigateToDetailsView(toDoObj, false);
                            },
                            child: ListTile(
                                title: Text(toDoObj.title),
                                subtitle: Text(toDoObj.description),
                                trailing: GestureDetector(
                                  child: Icon(Icons.delete),
                                  onTap: () {
                                    deleteItem(toDoObj);
                                  },
                                )),
                          )));
                }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          navigateToDetailsView(ToDo("", "", "", ""), true);
        },
      ),
    );
  }

  Border isTaskCompleted(bool isCompleted) {
    return Border(
      left: BorderSide(
          width: 10.0, color: Color(isCompleted ? 0xFFd4edda : 0xFFefc56f)),
    );
  }

  Future udpateListView() async {
    _toDoList = await databaseHelper.getDataModelsFromMapList();

    setState(() {
      _toDoList = _toDoList;
      count = _toDoList.length;
    });
  }

  ListView getToDoListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (context, index) {
          ToDo toDoObj = _toDoList[index];
          bool isCompleted = toDoObj.status.toLowerCase() == "completed";
          return Container(
              child: Card(
                  color: isCompleted ? Colors.green : Colors.orange,
                  child: GestureDetector(
                    onTap: () {
                      navigateToDetailsView(toDoObj, false);
                    },
                    child: ListTile(
                        title: Text(toDoObj.title),
                        subtitle: Text(toDoObj.description),
                        leading: isCompleted
                            ? Icon(Icons.done_all)
                            : Icon(Icons.warning),
                        trailing: GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: () {
                            deleteItem(toDoObj);
                          },
                        )),
                  )));
        });
  }

  navigateToDetailsView(ToDo toDoObj, bool isNewForm) async {
    bool results =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ToDoForm(toDoObj, isNewForm);
    }));

    if (results != null) {
      udpateListView();
    }
  }

  deleteItem(ToDo toDoObj) async {
    int result = await databaseHelper.deleteItemFromDB(toDoObj);
    if (result != 0) {
      var snackbar = SnackBar(
        content: Text("Deleted"),
        backgroundColor: Colors.grey,
      );
      udpateListView();
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
}
