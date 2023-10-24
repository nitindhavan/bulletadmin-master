import 'package:bulletadmin/model/exam.dart';
import 'package:bulletadmin/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value){
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:Colors.blue,
        scaffoldBackgroundColor: Color(0xffF6F2FF),
        appBarTheme: const AppBarTheme(color: Color(0xff3D1975),toolbarHeight: 70),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selected='Exams';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bullet Admin'),),
      body: Row(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children:[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(Icons.pages,color: selected == 'Exams' ? Color(0xff3D1975) : Colors.black,),
                ),
              ]
            ),
          ),
          Expanded(child: Container(color: Colors.white,child: selected=='Exams' ? ExamsPage() : SizedBox(),)),
        ],
      ),
    );
  }
}

