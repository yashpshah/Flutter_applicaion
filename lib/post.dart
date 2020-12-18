import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'addComment.dart';
import 'addRate.dart';

class Post extends StatelessWidget {
  final int pid;
  Post(this.pid);
  Future _getPost(int pid) async {
    try {
      final url =
          'https://bismarck.sdsu.edu/api/instapost-query/post?post-id=$pid';
      final response = await http.get(
        url,
      );
      final r = jsonDecode(response.body);
      if (r['post']['image'] != -1) {
        try {
          final url =
              'https://bismarck.sdsu.edu/api/instapost-query/image?id=${r['post']['image']}';
          final newresponse = await http.get(
            url,
          );
          return [r, jsonDecode(newresponse.body)['image']];
        } catch (e) {
          return [r, -1];
        }
      }
      return [r, -1];
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getPost(pid),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          dynamic posts = snapshot.data[0]['post'];
          dynamic image;
          Uint8List decodedBytes;
          if (snapshot.data[1] != -1) {
            try {
              decodedBytes = base64Decode(snapshot.data[1]);
              image = true;
            } catch (e) {}
          }

          return Column(
            children: [
              (image == true) ? Image.memory(decodedBytes) : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('${posts['title']}'),
                  Text('${posts['hashtags'].join(' ')}'),
                  Text('ratings- ${posts['ratings-average']}/5'),
                  Divider(),
                ],
              ),
              Text(
                  '${posts['comments'].length == 0 ? '' : posts['comments'].join(',')}'),
              RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommentInput(posts['id'])),
                    );
                  },
                  child: Text('comment')),
              RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RateInput(posts['id'])),
                    );
                  },
                  child: Text('rate')),
            Divider(),],

          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
