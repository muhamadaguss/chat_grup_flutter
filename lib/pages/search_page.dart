import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/chat_page.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? snapshot;
  bool hasUserSearch = false;
  String userName = '';
  User? user;
  bool isJoined = false;

  @override
  void initState() {
    getCurrentUserIdandName();
    super.initState();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    user = FirebaseAuth.instance.currentUser;
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'SEARCH',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: textInputDecoration.copyWith(
                      border: InputBorder.none,
                      hintText: 'Search groups...',
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    initiateSearchMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : groupList()
        ],
      ),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService().searchByName(searchController.text).then((value) {
        setState(() {
          snapshot = value;
          isLoading = false;
          hasUserSearch = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearch
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                snapshot!.docs[index]['groupId'],
                snapshot!.docs[index]['groupName'],
                snapshot!.docs[index]['admin'],
              );
            },
          )
        : Container();
  }

  joinedOrNot(String groupName, String groupId, String userName) async {
    await DatabaseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    joinedOrNot(groupName, groupId, userName);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        "Admin : ${getName(admin)}",
        style: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toogleGroup(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
              snowSnackbar(context, Colors.green, 'You have joined the group');
            });
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              snowSnackbar(context, Colors.red, 'You have left the group');
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10,
            ),
            color: isJoined ? Colors.black : Theme.of(context).primaryColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            isJoined ? 'Joined' : 'Join Now',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
