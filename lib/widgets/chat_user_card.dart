import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/view/chat_screen.dart';

import '../data/models/apis.dart';
import '../data/models/chat_user_model.dart';
import '../data/models/message_model.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/my_date_util.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUserModel user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // LAST MESSAGE INFO (IF NULL -> NO MESSAGE)
  MessageModel? _message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: StreamBuilder(
        stream: APIs.getLastMessage(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => MessageModel.fromJson(e.data())).toList() ?? [];
          if (list.isNotEmpty) _message = list[0];
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(user: widget.user),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    //USER PROFILE PHOTO
                    leading: ClipRRect(
                      borderRadius:
                          BorderRadiusDirectional.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        height: mq.height * .055,
                        width: mq.height * .055,
                        imageUrl: widget.user.image,
                        // placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    ),

                    //USER NAME
                    title: Text(widget.user.name),

                    //LAST MESSAGE
                    subtitle: Text(
                        _message != null
                            ? _message!.type == Type.image
                                ? 'Image'
                                : _message!.msg
                            : widget.user.about,
                        maxLines: 1),

                    //LAST MESSAGE TIME
                    trailing: _message == null
                        ? null
                        : _message!.read.isNotEmpty &&
                                _message!.fromID != APIs.user.uid
                            ? Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(20)),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(
                                    context, _message!.sent),
                                style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const Divider(
                color: dividerColor,
                indent: 85,
              ),
            ],
          );
        },
      ),
    );
  }
}
