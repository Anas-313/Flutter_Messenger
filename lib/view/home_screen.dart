import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_messenger/utils/routes/routes_name.dart';

import '../data/models/apis.dart';
import '../data/models/chat_user_model.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //FOR STORING ALL USERS
  List<ChatUserModel> _list = [];

  // FOR STORING SEARCHED USERS
  final List<ChatUserModel> _searchList = [];

  // FOR STORING SEARCH STATUS
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // FOR UPDATING USER STATUS TO ACTIVE
    APIs.updateActiveStatus(true);

    // FOR UPDATING USER ACTIVE STATUS ACCORDING TO LIFECYCLE EVENT
    // RESUME -> ACTIVE OR ONLINE
    // PAUSE -> INACTIVE OR OFFLINE
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.fAuth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          title: const Text(
            'WhatsApp',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // SEARCH USER BUTTON
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                });
              },
              icon: Icon(_isSearching
                  ? CupertinoIcons.clear_circled_solid
                  : Icons.search),
            ),

            // MORE ICON
            PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'new_group',
                  child: Text('New Group'),
                ),
                const PopupMenuItem(
                  value: 'new_broadcast',
                  child: Text('New Broadcast'),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('Settings'),
                ),
              ],
              onSelected: (value) {
                if (value == 'new_group') {
                  // Handle New Group action
                } else if (value == 'new_broadcast') {
                  // Handle New Broadcast action
                } else if (value == 'settings') {
                  Navigator.pushNamed(context, RoutesName.profile);
                }
              },
            ),
          ],
          // TAB BAR
          bottom: const TabBar(
              indicatorColor: tabColor,
              indicatorWeight: 4,
              labelColor: tabColor,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: [
                Tab(text: 'CHATS'),
                Tab(text: 'STATUS'),
                Tab(text: 'CALLS')
              ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: tabColor,
          child: const Icon(Icons.comment, color: iconColor),
        ),
        body: StreamBuilder(
          stream: APIs.getAllUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              //IF DATA IS LOADING
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );

              // IF SOME OR ALL DATA IS LOADED THEN SHOW IT
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                _list = data
                        ?.map((e) => ChatUserModel.fromJson(e.data()))
                        .toList() ??
                    [];
            }

            if (_list.isNotEmpty) {
              return ListView.builder(
                padding: EdgeInsets.only(top: mq.height * .01),
                physics: const BouncingScrollPhysics(),
                itemCount: _isSearching ? _searchList.length : _list.length,
                itemBuilder: (context, index) {
                  return ChatUserCard(
                      user: _isSearching ? _searchList[index] : _list[index]);
                },
              );
            } else {
              return const Center(
                child: Text(
                  'No Connections found',
                  style: TextStyle(fontSize: 20),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
