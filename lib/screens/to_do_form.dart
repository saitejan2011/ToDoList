import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:ToDoList/models/to_do_model.dart';
import 'package:ToDoList/utilities/db_helper.dart';

class ToDoForm extends StatefulWidget {
  ToDo toDoObj;
  bool isNewForm;
  ToDoForm(this.toDoObj, this.isNewForm);
  @override
  _PostToDoItemState createState() =>
      _PostToDoItemState(this.toDoObj, this.isNewForm);
}

class _PostToDoItemState extends State<ToDoForm> {
  ToDo toDoObj;
  bool isNewForm;

  DatabaseHelper databaseHelper = DatabaseHelper();
  _PostToDoItemState(this.toDoObj, this.isNewForm);

  @override
  void initState() {
    currentStatus = toDoObj.status.length == 0 ? "Pending" : toDoObj.status;
    _titleEditingController.text = toDoObj.title;
    _descriptionEditingController.text = toDoObj.description;
  }

  List<String> _statusList = ["Pending", "Completed"];
  String currentStatus = "Pending";

  TextEditingController _titleEditingController = TextEditingController();
  TextEditingController _descriptionEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              isNewForm ? Text("Create work item") : Text("Update work item")),
      body: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            DropdownButton(
                value: currentStatus,
                items: _statusList.map((item) {
                  return DropdownMenuItem(child: Text(item), value: item);
                }).toList(),
                onChanged: (val) {
                  onStatusDrpdownChange(val);
                }),
            SizedBox(height: 20),
            TextField(
              controller: _titleEditingController,
              decoration: InputDecoration(
                  hintText: "Enter Title",
                  labelText: "Title",
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionEditingController,
              decoration: InputDecoration(
                  hintText: "Enter Description",
                  labelText: "Description",
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Container(
                child: RaisedButton(
              onPressed: () {
                onSubmitBtnClick();
              },
              color: Colors.blue,
              child: isNewForm
                  ? Text(
                      "Create",
                      style: TextStyle(color: Colors.white),
                    )
                  : Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
            ))
          ],
        ),
      ),
    );
  }

  void onStatusDrpdownChange(String status) {
    return setState(() {
      currentStatus = status;
    });
  }

  void onSubmitBtnClick() async {
    this.onUpdateToDoObj();
    DatabaseHelper databaseHelper = DatabaseHelper();
    if (toDoObj.id == null) {
      await databaseHelper.insertItemInDB(toDoObj);
      Fluttertoast.showToast(msg: "${toDoObj.title} inserted successfully");
    } else {
      await databaseHelper.udpateItemInDB(toDoObj);
      Fluttertoast.showToast(msg: "${toDoObj.title} udpated successfully");
    }
    Navigator.pop(context, true);
  }

  void onUpdateToDoObj() {
    toDoObj.title = _titleEditingController.text;
    toDoObj.description = _descriptionEditingController.text;
    toDoObj.status = currentStatus;
    toDoObj.date = DateFormat.yMMMd().format(DateTime.now()).toString();
  }
}
