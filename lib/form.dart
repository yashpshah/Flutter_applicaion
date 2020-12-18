import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'hashtags.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      //padding:
                      //EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      //transform: Matrix4.rotationZ(-8 * pi / 180)
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'InstaPost',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 40,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

var _controller_email = new TextEditingController();
var _controller_password = new TextEditingController();

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'fname': '',
    'lname': '',
    'nickname': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    getEmail().then((String email) {
      setState(() {
        _controller_email.text = email;
      });
    });
    getPassword().then((String password) {
      setState(() {
        _controller_password.text = password;
      });
    });
    super.initState();
  }

  savePreferences() {
    String email = _controller_email.text;
    String password = _controller_password.text;
    saveData(email, password);
  }

  Future<bool> saveData(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("email", email);
    prefs.setString("password", password);
    return prefs.commit();
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email");
    return email;
  }

  Future<String> getPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String password = prefs.getString("password");
    return password;
  }

  Future _authenticate(String email, String password) async {
    final url =
        'https://bismarck.sdsu.edu/api/instapost-query/authenticate?email=$email&password=$password';
    final response = await http.get(
      url,
    );
    return jsonDecode(response.body);
  }

  Future signup(String firstname, String lastname, String nickname,
      String email, String password) async {
    const url = 'https://bismarck.sdsu.edu/api/instapost-upload/newuser';
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          'firstname': firstname,
          'lastname': lastname,
          'nickname': nickname,
          'email': email,
          'password': password,
        },
      ),
    );
    return jsonDecode(response.body);
  }

  Future login(String email, String password) async {
    return _authenticate(email, password);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.Login) {
      // Log user in
      final response =
          await _authenticate(_authData['email'], _authData['password']);
      if (response['result'] == true) {
        savePreferences();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HashTagList()),
        );
      } else {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Wrong info')));
      }
    } else {
      final response = await signup(_authData['fname'], _authData['lname'],
          _authData['nickname'], _authData['email'], _authData['password']);
      if (response['result'] == 'fail') {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(response['errors'])));
      } else {
        savePreferences();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HashTagList()),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _controller_email,
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  controller: _controller_password,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value.length < 3) {
                      return 'Password must be atleast 3 characters long!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                    _controller_password.text = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  Column(
                    children: [
                      TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _controller_password.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                      TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration: InputDecoration(labelText: 'FirstName'),
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value.isEmpty) {
                                  return 'Invalid!';
                                }
                              }
                            : null,
                        onSaved: (value) {
                          _authData['fname'] = value;
                        },
                      ),
                      TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration: InputDecoration(labelText: 'LastName'),
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value.isEmpty) {
                                  return 'Invalid!';
                                }
                              }
                            : null,
                        onSaved: (value) {
                          _authData['lname'] = value;
                        },
                      ),
                      TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration: InputDecoration(labelText: 'NickName'),
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value.isEmpty) {
                                  return 'Invalid!';
                                }
                              }
                            : null,
                        onSaved: (value) {
                          _authData['nickname'] = value;
                        },
                      ),
                    ],
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
