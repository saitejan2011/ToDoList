class ToDo {
  int id;
  String title;
  String description;
  String status;
  String date;

  ToDo(this.title, this.description, this.status, this.date);

  ToDo.withID(this.id, this.title, this.description, this.status, this.date);

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new Map();
    if (id != null) map["id"] = id;
    map["title"] = title;
    map["description"] = description;
    map["status"] = status;
    map["date"] = date;
    return map;
  }

  ToDo.fromMap(Map<String, dynamic> map) {
    id = map["id"];
    title = map["title"];
    description = map["description"];
    status = map["status"];
    date = map["date"];
  }
}
