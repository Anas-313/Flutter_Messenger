import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/utils/colors.dart';
import 'package:flutter_messenger/utils/routes/routes_name.dart';
import 'package:flutter_messenger/utils/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/apis.dart';
import '../data/models/chat_user_model.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // PICKED IMAGE PATH
  String? _imagePath;

  // Pick an image.
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // FOR HIDING KEYBOARD WHEN A TAP IS DETECTED ON SCREEN
      onTap: () => FocusScope.of(context).unfocus(),
      // FOR HIDING KEYBOARD
      child: Scaffold(
        //APP BAR
        appBar: AppBar(
          title: const Text('Profile Screen'),
          backgroundColor: mobileChatBoxColor,
        ),

        //LOGOUT BUTTON
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () {
              // FOR SHOWING PROGRESS DIALOG
              Utils.showProgressBar(context);

              APIs.updateActiveStatus(false);

              // SIGN OUT FROM APP
              APIs.fAuth.signOut().then((value) {
                GoogleSignIn().signOut().then((value) {
                  // FOR HIDING PROGRESS DIALOG
                  Navigator.pop(context);

                  // FOR MOVING TO HOME SCREEN
                  Navigator.pop(context);

                  APIs.fAuth = FirebaseAuth.instance;

                  // REPLACING HOME SCREEN TO LOGIN SCREEN
                  Navigator.pushReplacementNamed(context, RoutesName.login);
                });
              });
            },
            shape: const StadiumBorder(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // FOR ADDING SPACE
                  SizedBox(height: mq.height * .03, width: mq.width),

                  //USER PROFILE PHOTO
                  Stack(
                    children: [
                      _imagePath != null
                          ?
                          //LOCAL IMAGE
                          ClipRRect(
                              borderRadius: BorderRadiusDirectional.circular(
                                  mq.height * .1),
                              child: Image.file(File(_imagePath!),
                                  height: mq.height * .2,
                                  width: mq.height * .2,
                                  fit: BoxFit.cover),
                            )

                          //IMAGE FROM SERVER
                          : ClipRRect(
                              borderRadius: BorderRadiusDirectional.circular(
                                  mq.height * .1),
                              child: CachedNetworkImage(
                                height: mq.height * .2,
                                width: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                        child: Icon(CupertinoIcons.person)),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          shape: const CircleBorder(),
                          elevation: 1,
                          onPressed: () {
                            bottomSheet();
                          },
                          color: iconColor,
                          child: const Icon(Icons.edit, color: Colors.teal),
                        ),
                      )
                    ],
                  ),

                  // FOR ADDING SPACE
                  SizedBox(height: mq.height * .03, width: mq.width),

                  // USER EMAIL ID
                  Text(widget.user.email,
                      style: const TextStyle(color: textColor, fontSize: 18)),

                  // FOR ADDING SPACE
                  SizedBox(height: mq.height * .05, width: mq.width),

                  // USER NAME FIELD
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        label: const Text('Name'),
                        hintText: 'eg. Happy Developer',
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.teal),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),

                  // FOR ADDING SPACE
                  SizedBox(height: mq.height * .05, width: mq.width),

                  // USER ABOUT FIELD
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        label: const Text('About'),
                        hintText: 'eg. Feeling Happy',
                        prefixIcon:
                            const Icon(Icons.info_outline, color: Colors.teal),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16))),
                  ),

                  // FOR ADDING SPACE
                  SizedBox(height: mq.height * .05, width: mq.width),

                  // UPDATE PROFILE BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(mq.width * .5, mq.height * .06),
                        backgroundColor: Colors.teal),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then(
                          (value) => Utils.toastMessage(
                              'Profile updated Successfully !'),
                        );
                      }
                    },
                    icon: const Icon(Icons.edit, size: 30, color: iconColor),
                    label: const Text(
                      'UPDATE',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void bottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .05),
            children: [
              //PICK PROFILE PICTURE LABEL
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              //FOR ADDING SOME SPACE
              SizedBox(height: mq.height * .02),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // PICK PICTURE FROM GALLERY
                  ElevatedButton(
                    onPressed: () async {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        setState(() {
                          _imagePath = image.path;
                        });
                        if (mounted) {
                          APIs.updateProfilePicture(File(_imagePath!));
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        fixedSize: Size(mq.width * .3, mq.height * .15),
                        backgroundColor: iconColor),
                    child: const Image(
                        image: AssetImage('assets/images/photo.png')),
                  ),

                  // TAKE PICTURE FROM CAMERA BUTTON
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15),
                          backgroundColor: iconColor),
                      onPressed: () async {
                        // Capture a photo.
                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          setState(() {
                            _imagePath = photo.path;
                          });
                          if (mounted) {
                            APIs.updateProfilePicture(File(_imagePath!));
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Image(
                          image: AssetImage('assets/images/camera.png'),
                          color: Colors.teal)),
                ],
              )
            ],
          );
        });
  }
}
