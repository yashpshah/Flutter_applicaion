import 'dart:convert';

import 'post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostsByNickName extends StatelessWidget {
  final String nicknames;
  PostsByNickName(this.nicknames);
  Future _getPosts(String nicknames) async {
    try {
      final url =
          'https://bismarck.sdsu.edu/api/instapost-query/nickname-post-ids?nickname=${nicknames}';
      final response = await http.get(
        url,
      );
      return jsonDecode(response.body)['ids'];
    } catch (e) {
      {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$nicknames'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _getPosts(nicknames),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List posts = snapshot.data;
              List nicknameposts = [];
              for (int i = 0; i < posts.length; i++) {
                nicknameposts.add(Post(posts[i]));
              }
              return Column(children: <Widget>[
                ...nicknameposts,
              ]);
              // return Container();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
