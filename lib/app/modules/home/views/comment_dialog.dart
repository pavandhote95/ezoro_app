// comment_reply_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/home/controllers/community_controller.dart';

class CommentReplyDialog extends StatefulWidget {
  final CommunityController controller;
  final int postId;
  final int parentId;

  const CommentReplyDialog({
    Key? key,
    required this.controller,
    required this.postId,
    required this.parentId,
  }) : super(key: key);

  @override
  State<CommentReplyDialog> createState() => _CommentReplyDialogState();
}

class _CommentReplyDialogState extends State<CommentReplyDialog> {
  late final TextEditingController _replyController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Error', 'Reply cannot be empty',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await widget.controller.replyToComment(
        postId: widget.postId,
        parentId: widget.parentId,
        reply: text,
      );

      // If successful, close the dialog
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // controller already shows snackbars on failures, but handle unexpected errors
      Get.snackbar('Error', 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.mainBg,
      title: const Text('Reply to comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _replyController,
            maxLines: 4,
            minLines: 1,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonBg),
          onPressed: _isSending ? null : _sendReply,
          child: _isSending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Send Reply'),
        ),
      ],
    );
  }
}
