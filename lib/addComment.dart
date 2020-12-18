import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CommentInput extends StatelessWidget {
  int pid;
  CommentInput(this.pid);

  var _controller_comment = new TextEditingController();
  Future submit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    String password = prefs.getString('password');
    String comment = _controller_comment.text;
    const url = 'https://bismarck.sdsu.edu/api/instapost-upload/comment';
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "email": email,
          "password": password,
          "comment": comment,
          "post-id": pid,
        },
      ),
    );
    if (jsonDecode(response.body)['result'] == 'success') {
      Navigator.of(context).pop();
    } else {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)['errors'])));
    }
  }

  final _formKey = GlobalKey<FormState>();
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
                    controller: _controller_comment,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Add Comment',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'This field cannot be null';
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                  // RaisedButton(
                  //     child: Text("Add Comment"),
                  //     onPressed: () async {
                  //       if (_formKey.currentState.validate()) {
                  //         Route route = MaterialPageRoute(
                  //             builder: (context) => PostsByHashtag());
                  //       }
                  //     })
                ]))));
  }
}
