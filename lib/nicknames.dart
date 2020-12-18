import 'package:assignment2/postByNickName.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
// import './hashtag_posts.dart';

class NicknameList extends StatelessWidget {
  static const routeName = '/nicknames';

  Future<List> _getHashTags() async {
    try {
      final response = await http
          .get("https://bismarck.sdsu.edu/api/instapost-query/nicknames");
      final jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse['nicknames'];
    } catch (error) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hash Tags'),
      ),
      body: FutureBuilder(
        future: _getHashTags(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List hashData = snapshot.data;
            return ListView.builder(
              itemCount: hashData.length,
              itemBuilder: (BuildContext context, int index) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PostsByNickName(hashData[index])),
                          );
                        },
                        child: ListTile(
                          title: Text('${hashData[index]}'),
                          trailing: Icon(
                            Icons.chevron_right,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
