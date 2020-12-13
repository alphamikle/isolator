class Routes {
  static const String index = '/';
  static const String comments = '/comments';
  static String comment(int commentId) => '/comments/$commentId';
}
