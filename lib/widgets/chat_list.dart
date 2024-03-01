import 'package:flutter/material.dart';
import 'package:flutter_messenger/widgets/my_message_card.dart';
import 'package:flutter_messenger/widgets/sender_message_card.dart';

import '../data/models/apis.dart';
import '../data/models/message_model.dart';

class ChatList extends StatefulWidget {
  final MessageModel message;
  const ChatList({super.key, required this.message});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromID
        ? MyMessageCard(
            message: widget.message,
          )
        : SenderMessageCard(
            message: widget.message,
          );
  }
}
