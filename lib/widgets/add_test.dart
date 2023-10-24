import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/model/test_model.dart';
import 'package:bulletadmin/widgets/inputfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'button.dart';

class AddTest extends StatefulWidget {
  const AddTest({Key? key,required this.model}) : super(key: key);
  final ExamModel model;
  @override
  State<AddTest> createState() => _AddTestState();
}

class _AddTestState extends State<AddTest> {
  var testNameController=TextEditingController();
  var testTimeController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Test",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w900),),
          InputField(controller: testNameController, hint: 'Enter Test Name'),
          InputField(controller: testTimeController, hint: 'Test Time in Minutes'),
          Button(onPressed: () {
            var ref=FirebaseDatabase.instance.ref('tests');
            String id=ref.push().key!;
            if(testNameController.text.isNotEmpty && testTimeController.text.isNotEmpty) {
              int time=int.tryParse(testTimeController.text) ?? 0;
              if(time!=0) {
                TestModel model = TestModel(
                    testNameController.text, id, widget.model.id, time);
                testNameController.text = '';
                testTimeController.text = '';
                ref.child(id).set(model.toMap()).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Test Added !')));
                });
              }
            }
          }, text: 'Add Test',)
        ],
      ),
    );
  }
}
