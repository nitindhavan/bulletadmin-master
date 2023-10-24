import 'dart:io';
import 'dart:typed_data';

import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/model/question_model.dart';
import 'package:bulletadmin/model/test_model.dart';
import 'package:bulletadmin/widgets/inputfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';

import 'button.dart';

class AddQuestion extends StatefulWidget {
  const AddQuestion({Key? key, required this.model,this.question}) : super(key: key);
  final TestModel model;
  final Question? question;
  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  var testNameController = TextEditingController();
  var focusNode = FocusNode();
  Uint8List? file;
  int answer = 1;
  int marks=1;
  var questionController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    if(widget.question!=null){
      setState(() {
        answer=widget.question!.answer;
        marks=widget.question!.marks;
      });
    }
    return Container(
      padding: EdgeInsets.only(left: 0,right: 0),
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Question",style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),),
              ],
            ),
            InputField(
              controller: questionController,
              hint: 'Question',
              node: focusNode,
            ),
            RawKeyboardListener(
              focusNode: focusNode,
              child: widget.question!=null && file==null ? Image.network(widget.question!.imageUrl) :  file != null
                  ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.memory(
                        file!,
                        key: Key(file.toString()),
                      ),
                  )
                  : SizedBox() ,
              onKey: (x) async {
                if (x.isControlPressed && x.character == 'v') {
                  file = await Pasteboard.image;
                  setState(() {
                    file;
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 16),
              child: Text(
                'Options',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  button(1),button(2),button(3),button(4)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16,top: 16),
              child: Text(
                'Marks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  markButton(1),markButton(2),markButton(3),markButton(4)
                ],
              ),
            ),

            Button(
              onPressed: () {
                var ref = FirebaseDatabase.instance.ref('questions');
                String id = ref.push().key!;
                if(widget.question!=null) id=widget.question!.id;
                Question question=Question(id, widget.model.id, widget.model.examId, '', answer, marks);
                if(widget.question==null && file!=null) {
                  FirebaseStorage.instance.ref('questions').child(id).putData(
                      file!).then((p0) async {
                    question.imageUrl = await p0.ref.getDownloadURL();
                    ref.child(id).set(question.toMap()).then((value) {
                      setState(() {
                        file = null;
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Quesion Uploaded')));
                      });
                    });
                  });
                }else if(widget.question!=null && file==null){
                  widget.question!.answer=answer;
                  widget.question!.marks=marks;
                  ref.child(id).set(widget.question!.toMap()).then((value) {
                    setState(() {
                      file = null;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Quesion Uploaded')));
                    });
                  });
                }else{
                  widget.question!.answer=answer;
                  widget.question!.marks=marks;
                  FirebaseStorage.instance.ref('questions').child(id).putData(
                      file!).then((p0) async {
                    widget.question!.imageUrl = await p0.ref.getDownloadURL();
                  ref.child(id).set(widget.question!.toMap()).then((value) {
                    setState(() {
                      file = null;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Quesion Uploaded')));
                    });
                  });
                  });
                }
              },
              text: 'Add Question',
            )
          ],
        ),
      ),
    );
  }

  Widget button(int index) {
    return Expanded(
      child: GestureDetector(
          onTap: () {
            setState(() {
              answer = index;
              if(widget.question!=null) widget.question!.answer=index;
            });
          },
          child: Container(
            alignment: Alignment.center,
            height: 60,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: answer == index ? Color(0xff3D1975) : Colors.white),
            child: Text(
              '$index',
              style: TextStyle(
                  color: answer == index ? Colors.white : Colors.black),
            ),
          )),
    );
  }
  Widget markButton(int index) {
    return Expanded(
      child: GestureDetector(
          onTap: () {
            setState(() {
              marks = index;
              if(widget.question!=null) widget.question!.marks=index;
            });
          },
          child: Container(
            alignment: Alignment.center,
            height: 60,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: marks == index ? Color(0xff3D1975) : Colors.white),
            child: Text(
              '$index',
              style: TextStyle(
                  color: marks == index ? Colors.white : Colors.black),
            ),
          )),
    );
  }
}
