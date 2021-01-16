import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future saveDeviceToken(FirebaseMessaging _fcm) async {
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokens = userCollection.doc(uid).collection('tokens').doc(fcmToken);
      return await tokens.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  Future<String> getNumber() async {
    String number = "";
    await userCollection
        .doc(uid)
        .collection("EmergencyContacts")
        .orderBy("priority")
        .get()
        .then((snapshot) {
      number = snapshot.docs[0].data()['number'];
    });
    print("num");
    print(number);
    return number;
  }

  Future<String> getName() async {
    String name = "";
    await userCollection.doc(uid).get().then((snapshot) {
      name = snapshot.data()['name'];
    });
    return name;
  }

  Future<String> getEmail() async {
    String email = "";
    await userCollection.doc(uid).get().then((snapshot) {
      email = snapshot.data()['email'];
    });
    return email;
  }

  Future<String> getDeviceFCM() async {
    String id = "";
    String number = await getNumber();
    var tokens = await userCollection.get().then((snapshot) async {
      for (DocumentSnapshot ds in snapshot.docs) {
        print(ds.data()['mobileNo']);
        print("mynum");
        print(number);
        if (ds.data()['mobileNo'] == number) {
          print("enter");
          try {
            id = await userCollection
                .doc(ds.id)
                .collection("tokens")
                .orderBy("createdAt")
                .get()
                .then((snapshot) => snapshot.docs[0].id);
            print(id);
          } on StateError catch (e) {
            print('No nested field exists!');
          }
          break;
        }
        print(id);
      }
    });
    return id;
  }

  Future<List<Contact>> getContact() async {
    List<Contact> selected = [];
    var contacts = await userCollection
        .doc(uid)
        .collection("EmergencyContacts")
        .orderBy('priority')
        .get()
        .then((snapshot) {
      if (snapshot.docs.length != 0)
        for (DocumentSnapshot ds in snapshot.docs) {
          selected.add(Contact(
              displayName: ds.data()['name'],
              phones: [Item(value: ds.data()['number'])]));
        }
    });
    return selected;
  }

  Future setContact(List<Contact> sContacts) async {
    var contacts = await userCollection
        .doc(uid)
        .collection("EmergencyContacts")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    var setContacts = userCollection.doc(uid).collection("EmergencyContacts");
    for (int i = 0; i < sContacts.length; i++) {
      await setContacts.add({
        "name": sContacts[i].displayName,
        "number": sContacts[i].phones.first.value,
        "priority": i + 1
      });
    }
  }

  Future updateUserData(String name, String mobileNo, String email) async {
    return await userCollection.doc(uid).set({
      "name": name,
      "mobileNo": '+91 $mobileNo',
      "email": email,
      "locId": 500072,
      "createdOn": DateTime.now()
    });
  }
}
