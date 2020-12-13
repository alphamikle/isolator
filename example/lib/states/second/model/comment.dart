class Comment {
  const Comment(this.id, this.title, this.url);

  factory Comment.fromJson(dynamic json) {
    final Comment comment = Comment(json['id'], json['title'], json['url']);
    return comment;
  }

  final int id;
  final String title;
  final String url;
}
