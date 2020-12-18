import 'dart:convert';

import 'package:assignment2/image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostInput extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  var _controller_title = new TextEditingController();
  var _controller_hash = new TextEditingController();

  Future submit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    String password = prefs.getString('password');
    String title = _controller_title.text;
    String hash = _controller_hash.text;
    const url = 'https://bismarck.sdsu.edu/api/instapost-upload/post';
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "email": email,
          "password": password,
          'text': title,
          'hashtags': [hash],
        },
      ),
    );
    if (jsonDecode(response.body)['result'] == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddImage(jsonDecode(response.body)['id']),
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(jsonDecode(response.body)['result']),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _controller_title,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Add Post text',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter post Text';
                  } else if (value.length > 144) {
                    return 'Should be less than 144 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controller_hash,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Add hashtags',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter hashtag';
                  }
                  return null;
                },
              ),
              RaisedButton(
                child: Text('Add'),
                onPressed: () => submit(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).primaryTextTheme.button.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
