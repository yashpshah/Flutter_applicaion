import 'nicknames.dart';
import 'postsByHashtag.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import './hashtag_posts.dart';

class HashTagList extends StatelessWidget {
  static const routeName = '/hashtags';

  Future<List> _getHashTags() async {
    try {
      final response = await http
          .get("https://bismarck.sdsu.edu/api/instapost-query/hashtags");
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['hashtags'];
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
                return Column(
                  children: [
                    InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PostsByHashtag(hashData[index])),
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
      floatingActionButton: FloatingActionButton(
          child: Text('Nicknames'),
          onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NicknameList()),
                ),
              }),
    );
  }
}
