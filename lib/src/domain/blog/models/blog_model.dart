import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String imageURL;
  final String title;
  final String summary;
  final String content;
  final String deeplink;
  final DateTime publishedDate;
  final String author;
  final List<String> tags;
  final int readTimeMinutes;

  BlogPost({
    required this.id,
    required this.imageURL,
    required this.title,
    required this.summary,
    required this.content,
    required this.deeplink,
    required this.publishedDate,
    required this.author,
    this.tags = const [],
    this.readTimeMinutes = 5,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] ?? '',
      imageURL: json['imageURL'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      deeplink: json['deeplink'] ?? '',
      publishedDate:
          json['publishedDate'] != null
              ? (json['publishedDate'] as Timestamp).toDate()
              : DateTime.now(),
      author: json['author'] ?? 'Unknown Author',
      tags: List<String>.from(json['tags'] ?? []),
      readTimeMinutes: json['readTimeMinutes'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageURL': imageURL,
      'title': title,
      'summary': summary,
      'content': content,
      'deeplink': deeplink,
      'publishedDate': publishedDate,
      'author': author,
      'tags': tags,
      'readTimeMinutes': readTimeMinutes,
    };
  }
}
