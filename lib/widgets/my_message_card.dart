import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/models/message_model.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/my_date_util.dart';

class MyMessageCard extends StatefulWidget {
  final MessageModel message;
  const MyMessageCard({super.key, required this.message});

  @override
  State<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends State<MyMessageCard> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mq.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          color: messageColor,
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

                    // IMAGE FILE MESSAGE
                    : ClipRRect(
                        borderRadius:
                            BorderRadiusDirectional.circular(mq.height * .01),
                        child: CachedNetworkImage(
                          height: mq.height * .4,
                          width: mq.height * .3,
                          fit: BoxFit.cover,
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(Icons.image, size: 70)),
                        ),
                      ),
              ),
              Positioned(
                  bottom: 4,
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
                      // DOUBLE TICK BLUE ICON FOR READ MESSAGE

                      widget.message.read.isNotEmpty
                          ? const Icon(Icons.done_all_rounded,
                              color: Colors.blue, size: 20)
                          // DOUBLE TICK ICON FOR RECEIVED MESSAGE
                          : const Icon(Icons.done_all_rounded, size: 20),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
