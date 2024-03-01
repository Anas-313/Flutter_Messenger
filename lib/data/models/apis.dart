import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'chat_user_model.dart';
import 'message_model.dart';

class APIs {
  //FOR FIREBASE AUTHENTICATION
  static FirebaseAuth fAuth = FirebaseAuth.instance;

  //FOR ACCESSING CLOUD FIRESTORE
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // FOR ACCESSING FIREBASE STORAGE
  static FirebaseStorage storage = FirebaseStorage.instance;

  // TO RETURN CURRENT USER
  static User get user => fAuth.currentUser!;

  // FOR STORING SELF INFO
  static late ChatUserModel me;

  // FOR CHECKING IF USER EXITS OR NOT?
  static Future<bool> userExits() async {
    return (await firestore.collection('user').doc(user.uid).get()).exists;
  }

  // FOR GETTING CURRENT USER INFO
  static Future<void> getSelfInfo() async {
    await firestore.collection('user').doc(user.uid).get().then((user) {
      if (user.exists) {
        me = ChatUserModel.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        createUser().then((value) => getSelfInfo());
      }
    });
  }

  // FOR CREATING NEW USER
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final createNewChatUser = ChatUserModel(
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: 'Hey, I am using ChatSphere',
      id: user.uid,
      isOnline: false,
      createdAt: time,
      lastActive: time,
      pushToken: '',
      image: user.photoURL.toString(),
    );

    return await firestore
        .collection('user')
        .doc(user.uid)
        .set(createNewChatUser.toJson());
  }

//FOR GETTING ALL USER FROM FIREBASE
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('user')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // FOR UPDATING USER INFORMATION
  static Future<void> updateUserInfo() async {
    await firestore.collection('user').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // UPDATING USER PROFILE PICTURE
  static Future<void> updateProfilePicture(File file) async {
    // GETTING IMAGE FILE EXTENSION
    final ext = file.path.split('.').last;
    log('Extension : $ext');

    // STORAGE FILE REFERENCE WITH PATH
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    //UPLOAD IMAGE
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((pO) {
      log('Transferred Data : ${pO.bytesTransferred / 1000} KB');
    });

    //UPDATING IMAGE IN FIRESTORE DATABASE
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('user')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // FOR GETTING SPECIFIC USER STATUS INFORMATION
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserStatus(
      ChatUserModel chatUser) {
    return firestore
        .collection('user')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // UPDATE ONLINE OR LAST ACTIVE STATUS OF USER
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('user').doc(user.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().microsecondsSinceEpoch.toString()
    });
  }

  /// ************** CHAT SCREEN RELATED APIs **************

  // chats (collection) --> conversion_id (docs) --> messages --> (collection) --> message (docs)

  // FOR GETTING CONVERSION ID
  static getConversionId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //FOR GETTING ALL MESSAGES OF A  SPECIFIC CONVERSATION FROM  FIRESTORE DATABASE
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUserModel chatUser) {
    return firestore
        .collection('chats/${getConversionId(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // FOR SENDING MESSAGE
  static Future<void> sendMessage(
      ChatUserModel chatUser, String msg, Type type) async {
    // MESSAGE SENDING TIME (ALSO USED AS ID)
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    // MESSAGE TO SEND
    final MessageModel message = MessageModel(
      toID: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      sent: time,
      fromID: user.uid,
    );

    final ref =
        firestore.collection('chats/${getConversionId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  // UPDATE READ MESSAGE STATUS
  static Future<void> updateReadMessageStatus(MessageModel message) async {
    firestore
        .collection('chats/${getConversionId(message.fromID)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

// GET ONLY LAST MESSAGE FOR SPECIFIC CHAT
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUserModel chatUser) {
    return firestore
        .collection('chats/${getConversionId(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // SEND CHAT IMAGE
  static Future<void> sendChatImage(ChatUserModel chatUser, File file) async {
    // GETTING IMAGE FILE EXTENSION
    final ext = file.path.split('.').last;

    // STORAGE FILE REFERENCE WITH PATH
    final ref = storage.ref().child(
        'images/${getConversionId(user.uid)}/${DateTime.now().microsecondsSinceEpoch}.$ext');

    //UPLOAD IMAGE
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((pO) {
      log('Transferred Data : ${pO.bytesTransferred / 1000} KB');
    });

    //UPDATING IMAGE IN FIRESTORE DATABASE
    final imageURL = await ref.getDownloadURL();
    await sendMessage(chatUser, imageURL, Type.image);
  }
}
