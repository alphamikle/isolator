import 'dart:math';

import 'package:dio/dio.dart';
import 'package:isolator/isolator.dart';

import '../../benchmark.dart';
import 'model/comment.dart';
import 'second_state.dart';

void createSecondBackend(BackendArgument<void> argument, {Dio? dio}) {
  SecondBackend(
    argument,
    dio ?? Dio(BaseOptions()),
  );
}

class SecondBackend extends Backend<SecondEvents> {
  SecondBackend(BackendArgument<void> argument, this.dio) : super(argument);

  final Dio dio;

  final List<Comment> _comments = [];
  final Map<SecondEvents, int> _startMicroseconds = {};

  void _startTimer(SecondEvents event) {
    _startMicroseconds[event] = DateTime.now().microsecondsSinceEpoch;
  }

  double? _getTimer(SecondEvents event) {
    final int? start = _startMicroseconds[event];
    final double? end = start == null ? null : (DateTime.now().microsecondsSinceEpoch - start) / 1000;
    if (end != null) {
      _startMicroseconds.remove(event);
    }
    return end;
  }

  void _endTimer(SecondEvents event) {
    final double? endTime = _getTimer(event);
    if (endTime == null) {
      send(SecondEvents.time, Packet2(event, null));
      return;
    }
    send(SecondEvents.time, Packet2(event, endTime));
  }

  Future<List<Comment>> _addItem(int commentId) async {
    send<void>(SecondEvents.startLoadingComment);
    _startTimer(SecondEvents.addItem);
    final Response<dynamic> response = await dio.get<dynamic>(
      'https://jsonplaceholder.typicode.com/photos/$commentId',
      options: Options(
        sendTimeout: commentId,
        receiveTimeout: commentId,
      ),
    );
    _endTimer(SecondEvents.addItem);
    final Comment comment = Comment.fromJson(response.data);
    _comments.insert(0, comment);
    send<void>(SecondEvents.endLoadingComment);
    return _comments;
  }

  List<Comment> _removeItem(int commentId) {
    _comments.removeWhere((Comment comment) => comment.id == commentId);
    return _comments;
  }

  Future<void> _loadComments(int limit) async {
    bench.start('Load comments on separate isolate');
    send<void>(SecondEvents.startLoadingComments);
    final Response<dynamic> photosResponse = await dio.get<dynamic>('https://jsonplaceholder.typicode.com/photos');
    final List<dynamic> allComments = <dynamic>[];
    for (int i = 0; i < 30; i++) {
      final Response<dynamic> commentsResponse = await Dio().get<dynamic>('https://jsonplaceholder.typicode.com/comments');
      allComments.addAll(commentsResponse.data as List<dynamic>);
    }
    int i = 0;
    final List<Comment> comments = (photosResponse.data as List<dynamic>).map((dynamic json) {
      json = <String, dynamic>{
        ...json,
        'comment': allComments[i]['comment'],
      };
      i++;
      return Comment.fromJson(json);
    }).toList();
    _comments.clear();
    _comments.addAll(comments.sublist(0, min(comments.length, limit)));
    await sendChunks(SecondEvents.loadComments, _comments);
    send<void>(SecondEvents.endLoadingComments);
    bench.end('Load comments on separate isolate');
  }

  void _clearComments() {
    _comments.clear();
    send(SecondEvents.clear, const <Comment>[]);
  }

  @override
  Future<void> onError(SecondEvents event, dynamic error) async {
    switch (event) {
      case SecondEvents.addItem:
        {
          send<void>(SecondEvents.endLoadingComment);
          send(SecondEvents.error, Packet2<double?, String>(_getTimer(event), error.toString()));
          break;
        }
      case SecondEvents.loadComments:
        {
          send<void>(SecondEvents.endLoadingComments);
          send(SecondEvents.error, Packet2<double?, String>(null, error.toString()));
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
        SecondEvents.clear: _clearComments,
      };
}
