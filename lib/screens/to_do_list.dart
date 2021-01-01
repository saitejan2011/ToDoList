import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ToDoList/models/to_do_model.dart';
import 'package:ToDoList/screens/to_do_form.dart';
import 'package:ToDoList/utilities/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<ToDo> _toDoList = null;
  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (_toDoList == null) {
      _toDoList = new List<ToDo>();
      udpateListView();
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("To Do List"),
          backgroundColor: Colors.blue,
          bottom: TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.white,
              indicatorColor: Colors.lime,
              onTap: (val) {
                print(val);
                setState(() {
                  currentTabIndex = val;
                });
              },
              tabs: [
                Tab(icon: Icon(Icons.all_inclusive), text: "All"),
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
        ),
        body: Container(
            child: Column(children: <Widget>[
          Expanded(child: getToDoListView(currentTabIndex))
        ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToDetailsView(ToDo("", "", "", ""), true);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  List<ToDo> getFilteredToDoList(int currentTabIndex) {
    switch (currentTabIndex) {
      case 1:
        return _toDoList
            .where((s) => s.status.toLowerCase() == "pending")
            .toList();
      case 2:
        return _toDoList
            .where((s) => s.status.toLowerCase() == "completed")
            .toList();
      default:
        return _toDoList;
    }
  }

  Future udpateListView() async {
    _toDoList = await databaseHelper.getDataModelsFromMapList();

    setState(() {
      _toDoList = _toDoList;
    });
  }

  ListView getToDoListView(int currentTabIndex) {
    List<ToDo> toDoList = getFilteredToDoList(currentTabIndex);
    return ListView.builder(
        itemCount: toDoList.length,
        itemBuilder: (context, index) {
          ToDo toDoObj = toDoList[index];
          bool isCompleted = toDoObj.status.toLowerCase() == "completed";
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
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onTap: () {
                            deleteItem(toDoObj);
                          },
                        )),
                  )));
        });
  }

  Border isTaskCompleted(bool isCompleted) {
    return Border(
      left: BorderSide(
          width: 10.0, color: Color(isCompleted ? 0xFFd4edda : 0xFFefc56f)),
    );
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
      Fluttertoast.showToast(msg: "${toDoObj.title} item deleted successfully");
      udpateListView();
    }
  }
}
