import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:login_ui/HomePage.dart';
import 'package:login_ui/MyAlerts.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:login_ui/services/DatabaseService.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class MessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;
  void init({BuildContext context}) {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) async {
        print(data);
        DatabaseService(uid: auth.FirebaseAuth.instance.currentUser.uid)
            .saveDeviceToken(_fcm);
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      DatabaseService(uid: auth.FirebaseAuth.instance.currentUser.uid)
          .saveDeviceToken(_fcm);
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        print(message);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyAlerts(
                    video: message['data']['video'].toString(),
                    lat: message['data']['latitude'],
                    long: message['data']['longitude'])));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyAlerts(
                    video: message['data']['video'].toString(),
                    lat: message['data']['latitude'],
                    long: message['data']['longitude'])));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MyAlerts(
                    video: message['data']['video'].toString(),
                    lat: message['data']['latitude'],
                    long: message['data']['longitude'])));
      },
    );
  }

  sendMessage(String videoLink) async {
    await DatabaseService(uid: auth.FirebaseAuth.instance.currentUser.uid)
        .getDeviceFCM()
        .then((deviceToken) async {
      print("here");
      print(deviceToken);
      await http
          .post("https://fcm.googleapis.com/fcm/send",
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'key=' +
                    'AAAAF5hTmw0:APA91bFCWXezQDKlKwfd1xFHpnWQoIzlrves0WtSpcYyN2kpz2GQzccL670-UEmU6Y1dc3WF7zkGX4r1EZHpe0Jy2O-k34ZjR91w9ivmRdBOa04ksCoOAs40zeZ5-abvhDbZAU_B9PcJ',
              },
              body: jsonEncode({
                'notification': {
                  'title': 'Alert',
                  'body': 'Your Friend is in danger Please contact them!!!',
                  "click_action": "FLUTTER_NOTIFICATION_CLICK"
                },
                'to': deviceToken,
                'priority': 'high',
                'data': {
                  "video": videoLink,
                  "latitude": HomePage.currentLocation.latitude,
                  "longitude": HomePage.currentLocation.longitude,
                },
              }))
          .then((value) async {
        print("done");
      });
    });
    // var deviceToken =
    //     "dNypPHPiTiOPJVA1wHbpHQ:APA91bEkzy7JgguX0zvzTgXIAPr6wHf96MSDdQW75znqbLgbaXUSoC5UWQdrjDAVYOhPFwOb7syrd5_eVZTQvdEhomVRAh8quxrSZIrU8Zln-MSgnO5lHBikfsufFXx2sXQbAQT07zto";
    await DatabaseService(uid: auth.FirebaseAuth.instance.currentUser.uid)
        .getNumber()
        .then((value) => UrlLauncher.launch('tel:$value'));
  }
}
