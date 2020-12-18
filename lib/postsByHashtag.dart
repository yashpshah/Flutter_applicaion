import 'dart:convert';

import 'addPost.dart';
import 'post.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class PostsByHashtag extends StatelessWidget {
  final String hashtag;
  PostsByHashtag(this.hashtag);
  Future _getPosts(String hashtag) async {
    try {
      hashtag = hashtag.replaceAll('#', '%23');
      final url =
          'https://bismarck.sdsu.edu/api/instapost-query/hashtags-post-ids?hashtag=${hashtag}';
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
        title: Text('$hashtag'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _getPosts(hashtag),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List posts = snapshot.data;
              List hposts = [];
              for (int i = 0; i < posts.length; i++) {
                hposts.add(Post(posts[i]));
              }
              return Column(children: <Widget>[
                ...hposts,
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
      floatingActionButton: FloatingActionButton(
          child: Text('+'),
          onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostInput()),
                ),
              }),
    );
  }
}
