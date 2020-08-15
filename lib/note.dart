import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Note extends StatefulWidget {
  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {

  TextEditingController keyInputController = new TextEditingController();
  TextEditingController valueInputController = new TextEditingController();

  File jsonFile;
  Directory dir;
  String fileName = "myJSONFile.json";
  bool fileExists = false;
  Map<String, dynamic> fileContent;

  void createFile(Map<String, dynamic> fileContent, Directory dir, String fileName) {
    print("Creating a file");
    File file = new File(p.join(dir.path, fileName));
    file.createSync();
    fileExists = true;
    print(fileContent.toString());
    file.writeAsStringSync(json.encode(fileContent));
    print("I am also here");
  }

  void writeFile(String key, String value) {
    print("Writing to the file");
    Map<String, dynamic> content = {key: value};
    if(fileExists) {
      print("File Exists");
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      List jsonList = jsonFileContent.values.toList(growable: true);
      print(jsonFile.readAsStringSync());
      print(jsonFileContent.toString());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      for(String a in jsonFileContent.keys) {
        print(jsonFileContent[a]);
      }
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
        this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyInputController.dispose();
    valueInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Backbutton pressed (device or appbar button), do whatever you want.');
        //trigger leaving and use own data
        Navigator.pop(context, false);
        //we need to return a future
        return Future.value(false);
      },
      child: Scaffold(
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () => writeFile(keyInputController.text, valueInputController.text),
            ),
          ],
        ),
        body: new Column(
          children: <Widget>[
            new Padding(padding: new EdgeInsets.only(top: 10.0)),
            new Text("File content: ", style: new TextStyle(fontWeight: FontWeight.bold),),
            new Text(fileContent.toString()),
            new Padding(padding: new EdgeInsets.only(top: 10.0)),
            new Text("Add to JSON file: "),
            new TextField(
              controller: keyInputController,
            ),
            new TextField(
              keyboardType: TextInputType.multiline,
              minLines: 3,
              maxLines: null,
              controller: valueInputController,
            ),
            new Padding(padding: new EdgeInsets.only(top: 20.0)),
//            new RaisedButton(
//              child: new Text("Add key, value pair"),
//              onPressed: () => writeFile(keyInputController.text, valueInputController.text),
//            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => writeFile(keyInputController.text, valueInputController.text),
          child: Icon(Icons.create),
          backgroundColor: Color(0xff212121),
        ),
      ),
    );
  }
}