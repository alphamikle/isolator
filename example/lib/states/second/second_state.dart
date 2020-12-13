import 'package:example/states/base_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:isolator/isolator.dart';

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
}

class SecondState extends BaseState<SecondEvents> {
  SecondState(this.firstState, this.rootContext);

  final FirstState firstState;
  final BuildContext rootContext;

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
    await initBackend(createSecondBackend);
  }

  void loadComments() {
    send(SecondEvents.loadComments, firstState.counter);
  }

  void _addComment(int counter) {
    send(SecondEvents.addItem, counter);
  }

  void _refreshComments(List<Comment> comments) {
    this.comments.clear();
    this.comments.addAll(comments);
  }

  void _notifyAboutOperation(Packet2<SecondEvents, double> packet) {
    String message = '${packet.value} took unknown time';
    if (packet.value2 != null) {
      message = '${packet.value} took ${packet.value2}ms';
    }
    Scaffold.of(rootContext).removeCurrentSnackBar();
    Scaffold.of(rootContext).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _notifyAboutError(Packet2<double, String> packet) {
    Scaffold.of(rootContext).removeCurrentSnackBar();
    Scaffold.of(rootContext).showSnackBar(
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
      };

  @override
  void onBackendResponse() {
    notifyListeners();
  }
}
