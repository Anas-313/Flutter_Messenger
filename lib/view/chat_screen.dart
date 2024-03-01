import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_messenger/data/models/message_model.dart';
import 'package:flutter_messenger/view/view_profile_screen.dart';
import 'package:flutter_messenger/widgets/chat_list.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/apis.dart';
import '../data/models/chat_user_model.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/my_date_util.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // FOR SHORTING ALL MESSAGES
  List<MessageModel> _messageList = [];

  // FOR HANDLING MESSAGE TEXT CHANGES
  final _messageController = TextEditingController();

  // FOR STORING VALUE OF SHOWING OR HIDING EMOJI
  bool _showEmoji = false;

  // FOR CHECKING IF IMAGE IS UPLOADING OR NOT?
  bool _isUploading = false;

  // Pick an image.
  final ImagePicker picker = ImagePicker();

  // PICKED IMAGE PATH
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        automaticallyImplyLeading: false,
        flexibleSpace: _appBar(),
        actions: [
          // VIDEO CALLING BUTTON
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.video_call, color: iconColor),
          ),

          // CALLING BUTTON
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.call, color: iconColor)),

          // MORE BUTTON
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: iconColor)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: APIs.getAllMessages(widget.user),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //IF DATA IS LOADING
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: SizedBox());

                  // IF SOME OR ALL DATA IS LOADED THEN SHOW IT
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    // log('Data: ${jsonEncode(data![0].data())}');
                    _messageList = data
                            ?.map((e) => MessageModel.fromJson(e.data()))
                            .toList() ??
                        [];

                    if (_messageList.isNotEmpty) {
                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.only(top: mq.height * .01),
                        physics: const BouncingScrollPhysics(),
                        itemCount: _messageList.length,
                        itemBuilder: (context, index) {
                          return ChatList(
                            message: _messageList[index],
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text('Say Hii...👋',
                            style: TextStyle(fontSize: 20)),
                      );
                    }
                }
              },
            ),
          ),
          if (_isUploading)
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 1),
              ),
            ),
          _chatInput(),

          // EMOJI WIDGET
          if (_showEmoji)
            SizedBox(
              height: mq.height * .34,
              child: EmojiPicker(
                textEditingController: _messageController,
                config: Config(
                  columns: 8,
                  emojiSizeMax: 32 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.30
                          : 1.0),
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  initCategory: Category.RECENT,
                  recentsLimit: 28,
                  noRecents: const Text(
                    'No Resents',
                    style: TextStyle(fontSize: 20, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                  loadingIndicator: const SizedBox.shrink(),
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  categoryIcons: const CategoryIcons(),
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            )
        ],
      ),
    );
  }

  // APP BAR WIDGET
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getUserStatus(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUserModel.fromJson(e.data())).toList() ??
                    [];

            return Padding(
              padding: EdgeInsets.only(top: mq.height * .02),
              child: Row(
                children: [
                  // BACK BUTTON
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),

                  // USER PROFILE PICTURE
                  ClipRRect(
                    borderRadius:
                        BorderRadiusDirectional.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      height: mq.height * .05,
                      width: mq.height * .05,
                      fit: BoxFit.cover,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  // FOR ADDING SOME SPACE
                  SizedBox(width: mq.width * .03),

                  // USER NAME & LAST SEEN TIME
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // USER NAME
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: textColor),
                      ),

                      // LAST SEEN TIME
                      Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive)
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: widget.user.lastActive),
                          style:
                              const TextStyle(color: textColor, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            );
          },
        ));
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .02, vertical: mq.height * .01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  // EMOJI BUTTON
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(Icons.emoji_emotions),
                    color: iconColor,
                  ),
                  Expanded(
                    // MESSAGE INPUT
                    child: TextFormField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() => _showEmoji = !_showEmoji);
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type Something,....',
                        hintStyle: TextStyle(
                            color: iconColor, fontWeight: FontWeight.w300),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  //PICK IMAGE FROM GALLERY BUTTON
                  IconButton(
                      onPressed: () async {
                        // PICK MULTIPLE IMAGES
                        final List<XFile?> images =
                            await picker.pickMultiImage();
                        if (images.isNotEmpty) {
                          setState(() => _isUploading = true);

                          // UPLOADING AND SENDING IMAGES ONE BY ONE
                          for (var i in images) {
                            if (mounted) {
                              await APIs.sendChatImage(
                                  widget.user, File(i!.path));
                              setState(() => _isUploading = false);
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.image),
                      color: iconColor),

                  //CAPTURE IMAGE FROM CAMERA BUTTON
                  IconButton(
                      onPressed: () async {
                        // Capture a photo.
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          setState(() => _isUploading = true);
                          if (mounted) {
                            await APIs.sendChatImage(
                                widget.user, File(_imagePath!));
                            setState(() => _isUploading = false);
                          }
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      color: iconColor),
                ],
              ),
            ),
          ),

          // SEND MESSAGE BUTTON
          MaterialButton(
            shape: const CircleBorder(),
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 05),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                APIs.sendMessage(
                    widget.user, _messageController.text, Type.text);
                _messageController.text = '';
              }
            },
            color: messageColor,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
