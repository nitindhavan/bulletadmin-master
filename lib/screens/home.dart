import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/model/question_model.dart';
import 'package:bulletadmin/model/test_model.dart';
import 'package:bulletadmin/screens/exam_details.dart';
import 'package:bulletadmin/widgets/add_test.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/add_exam.dart';
class ExamsPage extends StatefulWidget {
  const ExamsPage({Key? key}) : super(key: key);

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  var addExam=false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffF6F2FF),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text("Exams",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w900),),
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    addExam=!addExam;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0,right: 16),
                  child: Text(addExam? "Hide" : "Add Exam",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900),textAlign: TextAlign.center,),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: StreamBuilder(builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if(!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xff3D1975),));
                      List<ExamModel> modelList=[];
                      for(DataSnapshot snap in snapshot.data!.snapshot.children){
                        ExamModel model=ExamModel.fromMap(snap.value as Map);
                        modelList.add(model);
                      }
                      return GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7), itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ExamDetails(model: modelList[index])));
                          },
                          child: Card(
                            color: Colors.white,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(modelList[index].icon),
                                      )),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(modelList[index].name),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.more_vert),
                                ),
                                PopupMenuButton<int>(
                                  offset: const Offset(0, 0),
                                  itemBuilder: (context) => [
                                    PopupMenuItem<int>(
                                        value: 0,
                                        onTap: (){
                                          FirebaseDatabase.instance.ref('exams').child(modelList[index].id).remove().then((value){
                                            FirebaseStorage.instance.ref('exams').child(modelList[index].id).delete().then((value){
                                              FirebaseDatabase.instance.ref('tests').orderByChild('examId').equalTo(modelList[index].id).once().then((value) async {
                                                for(DataSnapshot snap in value.snapshot.children){
                                                  TestModel model=TestModel.fromMap(snap.value as Map);
                                                  await FirebaseDatabase.instance.ref('tests').child(model.id).remove();
                                                }
                                              });
                                              FirebaseDatabase.instance.ref('questions').orderByChild('examId').equalTo(modelList[index].id).once().then((value) async {
                                                for(DataSnapshot snap in value.snapshot.children){
                                                  Question model=Question.fromMap(snap.value as Map);
                                                  await FirebaseStorage.instance.ref('questions').child(model.id).delete();
                                                  await FirebaseDatabase.instance.ref('questions').child(model.id).remove();
                                                }
                                              });
                                            });
                                          });
                                        },
                                        child: Text('Delete'),),
                                    ])
                              ],
                            ),
                          ),
                        );
                      },itemCount: modelList.length,);
                    },stream: FirebaseDatabase.instance.ref('exams').onValue,),
                  ),
                  if(addExam)Container(color: Colors.black54,width: 2,),
                  if(addExam) Expanded(
                    flex: 1,
                    child: AddExam(),
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
