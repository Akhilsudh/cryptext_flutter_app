import 'dart:ffi';
import 'note.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File jsonFile;
  Directory dir;
  String fileName = "myJSONFile.json";
  bool fileExists = false;
  String filePresent;
  Map<String, dynamic> fileContent = new Map();

  void createFile(Map<String, dynamic> fileContent, Directory dir, String fileName) {
    print("Creating a file");
    File file = new File(p.join(dir.path, fileName));
    file.createSync();
    fileExists = true;
    print(fileContent.toString());
    file.writeAsStringSync(json.encode(fileContent));
    print("I am also here");
  }

  int itemCount() {
    fileContent = json.decode(jsonFile.readAsStringSync());
    return fileContent.length;
  }

  void onTapped() {
    print("I am clicked");
  }

  void writeFile(String key, String value) {
    print("Writing to the file");
    Map<String, dynamic> content = {key: value};
    if(fileExists) {
      print("File Exists");
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      print(jsonFile.readAsStringSync());
      print(jsonFileContent.toString());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    }
    else {
      print("File Does not exist");
      createFile(content, dir, fileName);
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(p.join(dir.path, fileName));
      fileExists = jsonFile.existsSync();
      if(fileExists) {
        print("I exist");
//        this.setState(() => filePresent = json.decode(jsonFile.readAsStringSync()).toString());
//        this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
      }
      else {
        print("I do not exist");
        this.setState(() => filePresent = "Click on the create button to create notes");
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color(0xff212121),
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.cover,
              height: 25.0,
            ),
          ],
        ),
      ),
      body: new Column(
        children: <Widget>[
//          new Text(filePresent),
          new Expanded(
              child: (!fileExists || itemCount() == 0) ? Center(child: Text(filePresent)) : new ListView.builder(
                  itemCount: itemCount(),
                  itemBuilder: (BuildContext context, int index){
                      String key = fileContent.keys.elementAt(index);
                      return ListTile(
                          title: Text(key),
                          subtitle: Text(fileContent[key]),
                          onTap: () => onTapped(),
                      );
                  },
              )
          )

          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          dynamic result = await Navigator.of(context).push(_createRoute());
          fileExists = jsonFile.existsSync();
          if(fileExists) {
            print("I exist");
            this.setState(() => filePresent = json.decode(jsonFile.readAsStringSync()).toString());
          }
          else {
            print("I do not exist");
            this.setState(() => filePresent = "Click on the create button to create notes");
          }
        },
        child: Icon(Icons.create),
        backgroundColor: Color(0xff212121),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Note(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
