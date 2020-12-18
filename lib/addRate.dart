import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RateInput extends StatelessWidget {
  int pid;
  RateInput(this.pid);

  var _controller_rate = new TextEditingController();
  Future submit(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    String password = prefs.getString("password");
    int rate = int.parse(_controller_rate.text);
    const url = 'https://bismarck.sdsu.edu/api/instapost-upload/rating';
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          {
            "email": email,
            "password": password,
            "rating": rate,
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
    } catch (e) {
      print(e);
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Rating'),
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  TextFormField(
                    controller: _controller_rate,
                    decoration: InputDecoration(
                      labelText: 'Add Rate',
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
