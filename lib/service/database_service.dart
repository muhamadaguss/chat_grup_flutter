import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //save database;
  Future savingData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'groups': [],
      'profilePic': '',
      'uid': uid,
    });
  }

  //getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  //get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //create group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': '${id}_$userName',
      'members': [],
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
    });
    //update members
    await groupDocumentReference.update({
      'members': FieldValue.arrayUnion(["${uid}_$userName"]),
      'groupId': groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      'groups':
          FieldValue.arrayUnion(['${groupDocumentReference.id}_$groupName']),
    });
  }

  //getting the chat
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot snapshot = await d.get();
    return snapshot['admin'];
  }

  //getting member chat
  getGroupMember(String groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search group
  searchByName(String groupName) async {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  //function -> bool

  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocReference = userCollection.doc(uid);
    DocumentSnapshot snapshot = await userDocReference.get();

    List<dynamic> groups = await snapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
      return false;
    }
  }

  //toogle join group
  Future toogleGroup(String groupId, String userName, String groupName) async {
    DocumentReference userDocReference = userCollection.doc(uid);
    DocumentReference groupDocReference = groupCollection.doc(groupId);

    DocumentSnapshot userSnapshot = await userDocReference.get();
    List<dynamic> groups = await userSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      await userDocReference.update({
        'groups': FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
      await groupDocReference.update({
        'members': FieldValue.arrayRemove(['${uid}_$userName'])
      });
    } else {
      await userDocReference.update({
        'groups': FieldValue.arrayUnion(['${groupId}_$groupName'])
      });
      await groupDocReference.update({
        'members': FieldValue.arrayUnion(['${uid}_$userName'])
      });
    }
  }

  //send message
  sendMessage(String groupId, Map<String, dynamic> messageData) async {
    groupCollection.doc(groupId).collection('messages').add(messageData);
    groupCollection.doc(groupId).update({
      'recentMessage': messageData['message'],
      'recentMessageSender': messageData['sender'],
      'recentMessageTime': messageData['time'].toString(),
    });
  }
}
