import 'dart:isolate';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:isolator/isolator.dart';

import 'model/comment.dart';
import 'second_state.dart';

void createSecondBackend(BackendArgument<void> argument, {Dio dio}) {
  SecondBackend(
    argument.toFrontend,
    dio ?? Dio(),
  );
}

class SecondBackend extends Backend<SecondEvents> {
  SecondBackend(SendPort sendPortToFront, this.dio) : super(sendPortToFront);

  final Dio dio;

  final List<Comment> _comments = [];

  Future<List<Comment>> _addItem(int commentId) async {
    send(SecondEvents.startLoadingComment);
    final int start = DateTime.now().microsecondsSinceEpoch;
    final Response<dynamic> response = await dio.get<dynamic>(
      'https://jsonplaceholder.typicode.com/photos/$commentId',
      options: RequestOptions(
        sendTimeout: 100,
        receiveTimeout: 100,
        connectTimeout: 100,
      ),
    );
    final double result = (DateTime.now().microsecondsSinceEpoch - start) / 1000;
    print('Time for loading one comment - ${result}ms');
    final Comment comment = Comment.fromJson(response.data);
    _comments.insert(0, comment);
    send(SecondEvents.endLoadingComment);
    return _comments;
  }

  List<Comment> _removeItem(int commentId) {
    _comments.removeWhere((Comment comment) => comment.id == commentId);
    return _comments;
  }

  Future<void> _loadComments() async {
    send(SecondEvents.startLoadingComments);
    final Response<dynamic> response = await dio.get<dynamic>('https://jsonplaceholder.typicode.com/photos');
    _comments.clear();
    final List<Comment> comments = (response.data as List<dynamic>).map((dynamic json) => Comment.fromJson(json)).toList();
    _comments.addAll(comments.sublist(0, min(comments.length, 100)));
    send(SecondEvents.loadComments, _comments);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    send(SecondEvents.endLoadingComments);
  }

  @override
  Map<SecondEvents, Function> get operations => {
        SecondEvents.addItem: _addItem,
        SecondEvents.removeItem: _removeItem,
        SecondEvents.loadComments: _loadComments,
      };
}
