import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/models/apis.dart';
import '../data/models/message_model.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/my_date_util.dart';

class SenderMessageCard extends StatefulWidget {
  final MessageModel message;
  const SenderMessageCard({super.key, required this.message});

  @override
  State<SenderMessageCard> createState() => _SenderMessageCardState();
}

class _SenderMessageCardState extends State<SenderMessageCard> {
  @override
  Widget build(BuildContext context) {
    // UPDATING READ MESSAGE STATUS
    if (widget.message.read.isEmpty) {
      APIs.updateReadMessageStatus(widget.message);
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mq.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          color: senderMessageColor,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 30, top: 5, bottom: 20),
                child: widget.message.type == Type.text
                    ?
                    // SHOW TEXT MESSAGE
                    Text(
                        widget.message.msg,
                        style: const TextStyle(fontSize: 15, color: textColor),
                      )
                    // SHOW IMAGE
                    : ClipRRect(
                        borderRadius:
                            BorderRadiusDirectional.circular(mq.height * .01),
                        child: CachedNetworkImage(
                          height: mq.height * .4,
                          width: mq.height * .3,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(Icons.image, size: 70)),
                        ),
                      ),
              ),
              Positioned(
                bottom: 2,
                right: 10,
                child: Row(
                  children: [
                    // MESSAGE TIME
                    Text(
                      MyDateUtil.getFormattedTime(
                          context: context, time: widget.message.sent),
                      style: const TextStyle(
                          fontSize: 13, color: messageTimeColor),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
