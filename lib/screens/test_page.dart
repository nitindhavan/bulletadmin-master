import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/model/question_model.dart';
import 'package:bulletadmin/screens/exam_details.dart';
import 'package:bulletadmin/widgets/add_question.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../model/test_model.dart';
import '../widgets/add_test.dart';
class TestPage extends StatefulWidget {
  const TestPage({Key? key,required this.examModel}) : super(key: key);

  final ExamModel examModel;
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TestModel? testModel;

  String mode='AddTest';

  Question? question;
  bool isTestVisible=true;
  bool questionListVisible=true;

  // var controller;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffF6F2FF),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          if(isTestVisible) Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("Tests",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                    ),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          mode='AddTest';
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0,right: 16),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: StreamBuilder(builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if(!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xff3D1975),));
                      List<TestModel> modelList=[];
                      if(!snapshot.data!.snapshot.exists) return Center(child: Text("No test Added"),);
                      for(DataSnapshot snap in snapshot.data!.snapshot.children){
                        TestModel model=TestModel.fromMap(snap.value as Map);
                        modelList.add(model);
                      }
                      return ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                testModel=modelList[index];
                                question=null;
                              });
                            },
                            child: Card(
                              color: testModel!=null && testModel!.id==modelList[index].id ? Color(0xff3D1975) : Colors.white,
                              child: Container(
                                  alignment: Alignment.bottomLeft,
                                  height: 50,
                                  padding: EdgeInsets.only(left: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(modelList[index].name,textAlign: TextAlign.center,style: TextStyle(color: testModel!=null && testModel!.id==modelList[index].id ? Colors.white : Colors.black,),),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: PopupMenuButton<int>(
                                            offset: const Offset(0, 0),
                                            icon: Icon(Icons.more_vert,color: testModel!=null && testModel!.id==modelList[index].id ? Colors.white : Colors.black,),
                                            itemBuilder: (context) => [
                                              PopupMenuItem<int>(
                                                value: 0,
                                                onTap: (){
                                                  FirebaseDatabase.instance.ref('tests').child(modelList[index].id).remove().then((value){
                                                    FirebaseDatabase.instance.ref('questions').orderByChild('testId').equalTo(modelList[index].id).once().then((value) async {
                                                      for(DataSnapshot snap in value.snapshot.children){
                                                        Question model=Question.fromMap(snap.value as Map);
                                                        await FirebaseStorage.instance.ref('questions').child(model.id).delete();
                                                        await FirebaseDatabase.instance.ref('questions').child(model.id).remove();
                                                      }
                                                    });
                                                  });
                                                },
                                                child: Text('Delete'),),
                                            ]),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        },itemCount: modelList.length,
                      );
                    },stream: FirebaseDatabase.instance.ref('tests').orderByChild('examId').equalTo(widget.examModel.id).onValue,),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: (){
                  setState(() {
                    isTestVisible=!isTestVisible;
                  });
                },
                  child: Icon(isTestVisible ? Icons.arrow_circle_left : Icons.arrow_circle_right
                  )),
              SizedBox(height: 12,),
              Expanded(child: Container(width: 2,color: Colors.black12,)),
            ],
          ),
          if(questionListVisible)Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text("Questions",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                    ),
                    GestureDetector(
                      onTap: (){
                        if(testModel!=null) {
                          setState(() {
                            mode = 'AddQuestion';
                            question = null;
                          });
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select test first")));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0,right: 16),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                testModel == null ? Expanded(child: Center(child: Text("Please select test"),)) : Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    child: StreamBuilder(key: Key(testModel.toString()),builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if(!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xff3D1975),));
                      if(!snapshot.data!.snapshot.exists) return Center(child: Text('No Questions available'));
                      List<Question> modelList=[];
                      for(DataSnapshot snap in snapshot.data!.snapshot.children){
                        Question model=Question.fromMap(snap.value as Map);
                        modelList.add(model);
                      }
                      return ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: (){
                              setState(() {
                                mode='AddQuestion';
                                question=modelList[index];
                              });
                            },
                            child: Card(
                              color: question!=null && question!.id==modelList[index].id ? Color(0xff3D1975) : Colors.white,
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 50,
                                  padding: EdgeInsets.only(left: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Question Number ${index+1}',textAlign: TextAlign.center,style: TextStyle(fontSize: 12,color: question!=null && question!.id==modelList[index].id ? Colors.white : Colors.black,),),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),
                                        child: PopupMenuButton<int>(
                                            offset: const Offset(0, 0),
                                            icon: Icon(Icons.more_vert,size: 12,color: question!=null && question!.id==modelList[index].id ? Colors.white : Colors.black,),
                                            itemBuilder: (context) => [
                                              PopupMenuItem<int>(
                                                value: 0,
                                                onTap: (){
                                                  FirebaseDatabase.instance.ref('questions').child(modelList[index].id).remove().then((value){
                                                    FirebaseStorage.instance.ref('questions').child(modelList[index].id).delete();
                                                  });
                                                },
                                                child: Text('Delete'),),
                                            ]),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        },itemCount: modelList.length,
                      );
                    },stream: FirebaseDatabase.instance.ref('questions').orderByChild('testId').equalTo(testModel!.id).onValue,),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                  onTap: (){
                    setState(() {
                      questionListVisible=!questionListVisible;
                    });
                  },
                  child: Icon(questionListVisible ? Icons.arrow_circle_left : Icons.arrow_circle_right
                  )),
              SizedBox(height: 12,),
              Expanded(child: Container(width: 2,color: Colors.black12,)),
            ],
          ),
          Expanded(
            flex: isTestVisible? 2: 3,
            child: Container(
              child : mode=='AddTest' ? AddTest(model: widget.examModel,) : mode=='AddQuestion' ? AddQuestion(model: testModel!,question: question,key: Key(question.toString()),): SizedBox()
          ),),
        ],
      ),
    );
  }
}
