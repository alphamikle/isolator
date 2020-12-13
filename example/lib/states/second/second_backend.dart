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
  final Map<SecondEvents, int> _startMicroseconds = {};

  void _startTimer(SecondEvents event) {
    _startMicroseconds[event] = DateTime.now().microsecondsSinceEpoch;
  }

  double _getTimer(SecondEvents event) {
    final int start = _startMicroseconds[event];
    final double end = start == null ? null : (DateTime.now().microsecondsSinceEpoch - start) / 1000;
    if (end != null) {
      _startMicroseconds.remove(event);
    }
    return end;
  }

  void _endTimer(SecondEvents event) {
    final double endTime = _getTimer(event);
    if (endTime == null) {
      send(SecondEvents.time, Packet2(event, null));
      return;
    }
    send(SecondEvents.time, Packet2(event, endTime));
  }

  Future<List<Comment>> _addItem(int commentId) async {
    send(SecondEvents.startLoadingComment);
    _startTimer(SecondEvents.addItem);
    final Response<dynamic> response = await dio.get<dynamic>(
      'https://jsonplaceholder.typicode.com/photos/$commentId',
      options: RequestOptions(
        sendTimeout: commentId,
        receiveTimeout: commentId,
        connectTimeout: commentId,
      ),
    );
    _endTimer(SecondEvents.addItem);
    final Comment comment = Comment.fromJson(response.data);
    _comments.insert(0, comment);
    send(SecondEvents.endLoadingComment);
    return _comments;
  }

  List<Comment> _removeItem(int commentId) {
    _comments.removeWhere((Comment comment) => comment.id == commentId);
    return _comments;
  }

  Future<void> _loadComments(int limit) async {
    send(SecondEvents.startLoadingComments);
    final Response<dynamic> response = await dio.get<dynamic>('https://jsonplaceholder.typicode.com/photos');
    _comments.clear();
    final List<Comment> comments = (response.data as List<dynamic>).map((dynamic json) => Comment.fromJson(json)).toList();
    _comments.addAll(comments.sublist(0, min(comments.length, limit)));
    send(SecondEvents.loadComments, _comments);
    await Future<void>.delayed(Duration(milliseconds: limit));
    send(SecondEvents.endLoadingComments);
  }

  @override
  Future<void> handleErrors(SecondEvents event, dynamic error) async {
    switch (event) {
      case SecondEvents.addItem:
        {
          send(SecondEvents.endLoadingComment);
          send(SecondEvents.error, Packet2<double, String>(_getTimer(event), error.toString()));
          break;
        }
      case SecondEvents.loadComments:
        {
          send(SecondEvents.endLoadingComments);
          send(SecondEvents.error, Packet2<double, String>(null, error.toString()));
          break;
        }
      default:
        {
          print('TODO: Handle errors of $event. Error is $error}');
        }
    }
  }

  @override
  Map<SecondEvents, Function> get operations => {
        SecondEvents.addItem: _addItem,
        SecondEvents.removeItem: _removeItem,
        SecondEvents.loadComments: _loadComments,
      };
}
