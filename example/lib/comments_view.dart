import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/states/second/model/comment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'states/first/first_state.dart';
import 'states/second/second_state.dart';

class CommentsView extends StatefulWidget {
  const CommentsView({Key? key}) : super(key: key);

  @override
  _CommentsViewState createState() {
    return _CommentsViewState();
  }
}

class _CommentsViewState extends State<CommentsView> {
  SecondState get secondState => Provider.of(context);
  SecondState get staticSecondState => Provider.of(context, listen: false);
  FirstState get firstState => Provider.of(context);
  FirstState get staticFirstState => Provider.of(context, listen: false);

  final ScrollController _itemsScrollController = ScrollController();

  Widget _itemBuilder(BuildContext context, int index) {
    final Comment comment = staticSecondState.getCommentByIndex(index);
    return ListTile(
      key: Key('${comment.id}'),
      title: Text(comment.title.substring(0, min(comment.title.length, 20))),
      subtitle: Text(comment.comment.substring(0, min(comment.comment.length, 30))),
      leading: CachedNetworkImage(imageUrl: comment.url, height: 56, width: 56),
      trailing: IconButton(onPressed: () => staticSecondState.removeComment(comment.id), icon: const Icon(Icons.clear), color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('View'),
            const SizedBox(width: 10),
            if (secondState.isCommentsLoading)
              const SizedBox(
                height: 30,
                width: 30,
                child: Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
                ),
              ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Clear all messages',
            child: IconButton(
              onPressed: secondState.clearComments,
              icon: const Icon(Icons.clear_all),
            ),
          ),
          Tooltip(
            message: 'Add 1 comment with ${firstState.counter} timeout',
            child: IconButton(
              onPressed: secondState.isCommentLoading ? null : secondState.addCommentAfterIncrement,
              icon: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: secondState.isCommentLoading ? 0.5 : 1,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Tooltip(
            message: 'Load ${firstState.counter} comments in separate isolate',
            child: IconButton(
              onPressed: secondState.isCommentsLoading ? null : secondState.loadComments,
              icon: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: secondState.isCommentsLoading ? 0.5 : 1,
                child: const Icon(Icons.refresh_rounded),
              ),
            ),
          ),
          Tooltip(
            message: 'Load ${firstState.counter} comments in main isolate',
            child: IconButton(
              onPressed: secondState.isCommentsLoading ? null : secondState.loadCommentsOnMainIsolate,
              icon: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: secondState.isCommentsLoading ? 0.5 : 1,
                child: const Icon(Icons.update_rounded),
              ),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        controller: _itemsScrollController,
        child: ListView.builder(
          controller: _itemsScrollController,
          itemBuilder: _itemBuilder,
          itemCount: secondState.comments.length,
        ),
      ),
    );
  }
}
