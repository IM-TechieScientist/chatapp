import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/components/chat_text_field.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart';

class ChatPage extends StatefulWidget {
  final String receiverName; // Add this field
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverName, // Add this parameter
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String? _quotedMessageId;
  String? _quotedMessageText;
  bool _isCode = false;

  FocusNode chatFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    chatFocusNode.addListener(() {
      if (chatFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    chatFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void selectMessageToReply(String messageId, String messageText) {
    setState(() {
      _quotedMessageId = messageId;
      _quotedMessageText = messageText;
    });
  }

  void clearInput() {
    _messageController.clear();
    setState(() {
      _quotedMessageId = null;
      _quotedMessageText = null;
      _isCode = false;
    });
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String message = _messageController.text;
      if (_isCode) {
        message = '```$message```';
      }

      await _chatService.sendMessage(
        widget.receiverID,
        message,
        quotedMessageId: _quotedMessageId,
        quotedMessageText: _quotedMessageText,
      );

      clearInput();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
        title: Text(
          widget.receiverName, // Display the name
          style: GoogleFonts.poppins(
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.tertiary,
        ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
        color: Colors.grey[600],
        height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 10.0,right: 10.0,bottom: 5.0,top:5.0),
              child: _buildMessageList(),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 30.0),
            child: _buildUserInput(context),
          )
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;

    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("error");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading...");
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
            );
          }
        });

        return ListView(
          padding: const EdgeInsets.only(bottom: 0.0),
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(context, doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(BuildContext context, DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    return GestureDetector(
      onLongPress: () => selectMessageToReply(doc.id, data['message']),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            isCurrentUser: isCurrentUser,
            data: data,
            messageId: doc.id,
            userId: data["senderID"],
            onReply: selectMessageToReply,
            quotedMessageText: data['quotedMessageText'],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput(BuildContext context) {
    return Column(
      children: [
        if (_quotedMessageText != null)
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Replying to: $_quotedMessageText',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _quotedMessageId = null;
                      _quotedMessageText = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Row(
            children: [
            Container(
              decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
              child: IconButton(
              icon: Icon(
                _isCode ? Icons.code_off : Icons.code,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              onPressed: () {
                setState(() {
                _isCode = !_isCode;
                });
              },
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: ChatTextField(
              controller: _messageController,
              hintText: "Message @${widget.receiverName}",
              obscureText: false,
              focusNode: chatFocusNode,
              ),
            ),
            const SizedBox(width: 10.0),
            Container(
              decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              ),
              child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
                Icons.arrow_upward,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              ),
  
            ),
            const SizedBox(width: 5.0),

          ],
        ),
      ],
    );
  }
}