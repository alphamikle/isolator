import 'dart:math';

import 'package:dio/dio.dart';
import 'package:example/states/base_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isolator/isolator.dart';

import '../../benchmark.dart';
import '../first/first_state.dart';
import 'model/comment.dart';
import 'second_backend.dart';

enum SecondEvents {
  addItem,
  removeItem,
  loadComments,
  startLoadingComment,
  startLoadingComments,
  endLoadingComment,
  endLoadingComments,
  time,
  error,
  clear,
}

class SecondState extends BaseState<SecondEvents> {
  SecondState(this.firstState, this.state);

  final FirstState firstState;
  final ScaffoldState state;

  final List<Comment> comments = [];
  bool isCommentsLoading = false;
  bool isCommentLoading = false;

  Comment getCommentByIndex(int index) => comments[index];

  /// Example of using one state in another
  void addCommentAfterIncrement() {
    firstState.onEvent(FirstEvents.increment, () => _addComment(firstState.counter));
    firstState.increment();
  }

  void removeComment(int itemId) {
    send(SecondEvents.removeItem, itemId);
  }

  Future<void> initState() async {
    await initBackend(createSecondBackend, backendType: SecondBackend);
  }

  void loadComments() {
    send(SecondEvents.loadComments, firstState.counter);
  }

  Future<void> loadCommentsOnMainIsolate() async {
    bench.start('Load comments on main isolate');
    isCommentsLoading = true;
    notifyListeners();
    final Response<dynamic> photosResponse = await Dio().get<dynamic>('https://jsonplaceholder.typicode.com/photos');
    final List<dynamic> allComments = <dynamic>[];
    for (int i = 0; i < 12; i++) {
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
    this.comments.clear();
    this.comments.addAll(comments.sublist(0, min(comments.length, firstState.counter)));
    isCommentsLoading = false;
    notifyListeners();
    bench.end('Load comments on main isolate');
  }

  void clearComments() {
    send(SecondEvents.clear);
  }

  void _addComment(int counter) {
    send(SecondEvents.addItem, counter);
  }

  void _refreshComments(List<Comment> comments) {
    this.comments.clear();
    this.comments.addAll(comments);
  }

  void _notifyAboutOperation(Packet2<SecondEvents, double?> packet) {
    String message = '${packet.value} took unknown time';
    if (packet.value2 != null) {
      message = '${packet.value} took ${packet.value2}ms';
    }
    ScaffoldMessenger.of(state.context).removeCurrentSnackBar();
    ScaffoldMessenger.of(state.context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _notifyAboutError(Packet2<double, String> packet) {
    ScaffoldMessenger.of(state.context).removeCurrentSnackBar();
    ScaffoldMessenger.of(state.context).showSnackBar(
      SnackBar(
        content: Text(packet.value2, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Map<SecondEvents, Function> get tasks => {
        SecondEvents.addItem: _refreshComments,
        SecondEvents.removeItem: _refreshComments,
        SecondEvents.loadComments: _refreshComments,
        SecondEvents.startLoadingComment: () => isCommentLoading = true,
        SecondEvents.endLoadingComment: () => isCommentLoading = false,
        SecondEvents.startLoadingComments: () => isCommentsLoading = true,
        SecondEvents.endLoadingComments: () => isCommentsLoading = false,
        SecondEvents.time: _notifyAboutOperation,
        SecondEvents.error: _notifyAboutError,
        SecondEvents.clear: _refreshComments,
      };

  @override
  void onBackendResponse() {
    notifyListeners();
  }
}
