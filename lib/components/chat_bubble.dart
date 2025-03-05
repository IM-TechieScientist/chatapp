import 'package:chat_app/components/chat_text.dart';
import 'package:chat_app/helpers/date_helper.dart';
// import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isCurrentUser;
  final String messageId;
  final String userId;
  final Function(String, String) onReply;
  final String? quotedMessageText;

  ChatBubble({
    super.key,
    required this.isCurrentUser,
    required this.data,
    required this.messageId,
    required this.userId,
    required this.onReply,
    this.quotedMessageText,
  });

  final DateHelper _dateHelper = DateHelper();

  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  Icons.reply,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: ChatText(
                  text: 'Reply',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  onReply(messageId, data['message']);
                },
              ),
              // ListTile(
              //   leading: Icon(
              //     Icons.block,
              //     color: Theme.of(context).colorScheme.tertiary,
              //   ),
              //   title: ChatText(
              //     text: 'Block user',
              //     size: 15,
              //     fontWeight: FontWeight.w500,
              //     color: Theme.of(context).colorScheme.tertiary,
              //   ),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _blockuser(context, userId);
              //   },
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                title: ChatText(
                  text: 'Close',
                  size: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                onTap: () => Navigator.pop(context),
              )
            ],
          ),
        );
      },
    );
  }

  // void _reportMessage(BuildContext context, String messageId, String userId) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: ChatText(
  //         text: 'report message',
  //         size: 15,
  //         fontWeight: FontWeight.w500,
  //         color: Theme.of(context).colorScheme.surface,
  //       ),
  //       content: ChatText(
  //         text: 'are you sure you want to report this message?',
  //         size: 15,
  //         fontWeight: FontWeight.w500,
  //         color: Theme.of(context).colorScheme.surface,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: ChatText(
  //             text: 'no',
  //             size: 15,
  //             fontWeight: FontWeight.w500,
  //             color: Theme.of(context).colorScheme.surface,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             ChatService().reportUser(messageId, userId);
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: ChatText(
  //                   text: 'message reported',
  //                   size: 15,
  //                   fontWeight: FontWeight.w500,
  //                   color: Theme.of(context).colorScheme.tertiary,
  //                 ),
  //               ),
  //             );
  //           },
  //           child: ChatText(
  //             text: 'yes, report',
  //             size: 15,
  //             fontWeight: FontWeight.w500,
  //             color: Theme.of(context).colorScheme.surface,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  // void _blockuser(BuildContext context, String userId) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: ChatText(
  //         text: 'block user',
  //         size: 15,
  //         fontWeight: FontWeight.w500,
  //         color: Theme.of(context).colorScheme.surface,
  //       ),
  //       content: ChatText(
  //         text: 'are you sure you want to block this user?',
  //         size: 15,
  //         fontWeight: FontWeight.w500,
  //         color: Theme.of(context).colorScheme.surface,
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: ChatText(
  //             text: 'no',
  //             size: 15,
  //             fontWeight: FontWeight.w500,
  //             color: Theme.of(context).colorScheme.surface,
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             ChatService().blockUser(userId);
  //             Navigator.pop(context); // FYI: Dismiss the dialog
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: ChatText(
  //                   text: 'user blocked',
  //                   size: 15,
  //                   fontWeight: FontWeight.w500,
  //                   color: Theme.of(context).colorScheme.tertiary,
  //                 ),
  //               ),
  //             );
  //             Navigator.pop(context); // FYI: Dismiss the page
  //           },
  //           child: ChatText(
  //             text: 'yes, block',
  //             size: 15,
  //             fontWeight: FontWeight.w500,
  //             color: Theme.of(context).colorScheme.surface,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondary
        ),
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (quotedMessageText != null)
              Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 4.0),
              decoration: BoxDecoration(
                color: Color(0xFF1b263b),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Replying to: $quotedMessageText',
                style: TextStyle(color: Colors.grey[400]),
              ),
              ),
            if (data["message"].startsWith("```") && data["message"].endsWith("```"))
                HighlightView(
                data["message"].substring(3, data["message"].length - 3),
                language: 'auto', // Auto-detect the language
                theme: {
                  'root': TextStyle(
                  backgroundColor: Colors.grey[900], // Dark background
                  color: Colors.white, // Light text color
                  ),
                  'keyword': TextStyle(color: Colors.cyanAccent),
                  'string': TextStyle(color: Colors.greenAccent),
                  'comment': TextStyle(color: Colors.grey),
                  'number': TextStyle(color: Colors.orangeAccent),
                  'literal': TextStyle(color: Colors.purpleAccent),
                  'type': TextStyle(color: Colors.blueAccent),
                },
                padding: const EdgeInsets.all(8),
                textStyle: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
                )
            else
              ChatText(
                text: data["message"],
                size: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            const SizedBox(height: 2.0),
            ChatText(
              text: _dateHelper.formatDatetime(data["timestamp"].toDate()),
              size: 8,
              fontWeight: FontWeight.w300,
              color:Theme.of(context).colorScheme.inversePrimary,
            ),
          ],
        ),
      ),
    );
  }
}