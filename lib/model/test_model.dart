class TestModel{
  String name;
  String id;
  String examId;
  int time;

  TestModel(this.name, this.id,this.examId, this.time);

  TestModel.fromMap(Map<dynamic, dynamic> map)
      : name = map['name'],
        id = map['id'],
        time=map['time'],
        examId=map['examId'];

  Map<String, Object?> toMap() {
    final map = {
      'name': name,
      'id': id,
      'examId': examId,
      'time': time
    };
    map.removeWhere((key, value) => value==null);
    return map;
  }
}