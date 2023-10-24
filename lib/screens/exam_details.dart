import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/screens/test_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class ExamDetails extends StatefulWidget {
  const ExamDetails({Key? key,required this.model}) : super(key: key);

  final ExamModel model;
  @override
  State<ExamDetails> createState() => _ExamDetailsState();
}

class _ExamDetailsState extends State<ExamDetails> {
  String selected='Test';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F2FF),
      appBar: AppBar(title: Text(widget.model.name),),
      body: Row(
        children: [
          // Container(
          //   color: Colors.white,
          //   child: Column(
          //       children:[
          //         Padding(
          //           padding: const EdgeInsets.all(16.0),
          //           child: Icon(Icons.pages,color: selected == 'Test' ? Color(0xff3D1975) : Colors.black,),
          //         ),
          //       ]
          //   ),
          // ),
          Expanded(child: Container(color: Colors.white,child: selected=='Test' ? TestPage(examModel: widget.model,) : SizedBox(),)),
        ],
      ),
    );

  }
}
