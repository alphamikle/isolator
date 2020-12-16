class Comment {
  const Comment(this.id, this.title, this.comment, this.url);

  factory Comment.fromJson(dynamic json) {
    final Comment comment = Comment(json['id'], json['title'], json['comment'] ?? 'No comments', json['url']);
    return comment;
  }

  final int id;
  final String title;
  final String comment;
  final String url;
}
