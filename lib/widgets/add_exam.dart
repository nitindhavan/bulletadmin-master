import 'dart:io';
import 'dart:typed_data';

import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/model/test_model.dart';
import 'package:bulletadmin/widgets/inputfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';

import 'button.dart';

class AddExam extends StatefulWidget {
  const AddExam({Key? key}) : super(key: key);
  @override
  State<AddExam> createState() => _AddExamState();
}

class _AddExamState extends State<AddExam> {
  var examNameController=TextEditingController();
  var aboutController=TextEditingController();
  Uint8List? file;
  var node=FocusNode();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          InputField(controller: examNameController, hint: 'Enter Exam Name',node: node,),
          InputField(controller: aboutController, hint: 'Enter details about exam'),
          RawKeyboardListener(
            focusNode: node,
            child: file != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.memory(
                file!,
                key: Key(file.toString()),
              ),
            )
                : SizedBox(),
            onKey: (x) async {
              if (x.isControlPressed && x.character == 'v') {
                file = await Pasteboard.image;
                setState(() {
                  file;
                });
              }
            },
          ),

          Button(onPressed: () async {
            var ref=FirebaseDatabase.instance.ref('exams');
            String id=ref.push().key!;
            if(examNameController.text.isNotEmpty) {
              ExamModel model = ExamModel(examNameController.text, id, aboutController.text, '', '');
              examNameController.text='';
              FirebaseStorage.instance.ref('exams').child(id).putData(file!).then((p0) async {
                model.icon= await p0.ref.getDownloadURL();
                ref.child(id).set(model.toMap()).then((value){
                  setState(() {
                    file=null;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exam Added')));
                  });
                });
              });
            }
          }, text: 'Add Exam',)
        ],
      ),
    );
  }
}
