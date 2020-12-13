import 'package:example/states/base_state.dart';
import 'package:flutter/widgets.dart';

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
    send(SecondEvents.loadComments);
  }

  void _addComment(int counter) {
    send(SecondEvents.addItem, counter);
  }

  void _refreshComments(List<Comment> comments) {
    this.comments.clear();
    this.comments.addAll(comments);
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
      };

  @override
  void onBackendResponse() {
    notifyListeners();
  }
}
