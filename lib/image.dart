import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddImage extends StatefulWidget {
  final int pid;
  AddImage(this.pid);
  @override
  _AddImageState createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  File _image;
  final picker = ImagePicker();
  Future getImage() async {
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
      }
    });
  }

  Future submit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    String password = prefs.getString('password');
    final encodedImage = base64Encode(_image.readAsBytesSync());
    const url = 'https://bismarck.sdsu.edu/api/instapost-upload/image';
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "email": email,
          "password": password,
          "image": encodedImage,
          "post-id": widget.pid,
        },
      ),
    );
    if (jsonDecode(response.body)['result'] == 'success') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Example'),
      ),
      body: Column(
        children: [
          Center(
            child: _image == null
                ? Text('No image selected.')
                : Image.file(_image),
          ),
          RaisedButton(
            onPressed: () => submit(context),
            child: Text('add'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
