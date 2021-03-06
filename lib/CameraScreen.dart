import 'dart:io';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:login_ui/HomePage.dart';
import 'package:login_ui/popUpDialog.dart';
import 'package:login_ui/services/MessageService.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:firebase_storage/firebase_storage.dart';

class CameraScreen extends StatefulWidget {
  static List<String> files = [];
  @override
  _CameraScreenState createState() {
    return new _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  bool _isRecording = false; // Bandera indicadora de grabación en proceso
  String _filePath;
  int endTime = DateTime.now().millisecondsSinceEpoch + (2) * 60 * 60;
  CountdownTimerController _timerController;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  String url = "";
  @override
  void initState() {
    super.initState();
    controller = new CameraController(cameras[0], ResolutionPreset.medium);
    _timerController = new CountdownTimerController(
        endTime: endTime,
        onEnd: () {
          _onStop();
          uploadPic();

          Navigator.push(_globalKey.currentContext,
              MaterialPageRoute(builder: (context) {
            popDialog(
                title: "Emergency Alert",
                context: context,
                content: "Notification Sent \n\n Video clip Sent");

            return HomePage();
          }));
        });

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _isRecording = true;
      _onRecord();
      setState(() {});
    });
  }

  void _onPlay() => OpenFile.open(_filePath);

  Future<void> _onStop() async {
    await controller.stopVideoRecording();
    CameraScreen.files.add(_filePath);
    print(CameraScreen.files[0]);
    setState(() => _isRecording = false);
    // dispose();
  }

  Future<void> _onRecord() async {
    var directory = await getTemporaryDirectory();
    _filePath = directory.path +
        '/${DateFormat('yyyymmddhhmmss').format(DateTime.now())}.mp4';
    controller.startVideoRecording(_filePath);
    setState(() => _isRecording = true);
  }

  Future uploadPic() async {
    String fileName = basename(_filePath);
    print(fileName);
    var ref = FirebaseStorage.instance.ref().child("Videos").child(fileName);
    url = await ref
        .putFile(File(_filePath))
        .then((res) => res.ref.getDownloadURL());
    Provider.of<MessageService>(_globalKey.currentContext, listen: false)
        .sendMessage(url);
    // var taskSnapshot = await uploadTask.;

    // Scaffold.of(_globalKey.currentContext)
    //     .showSnackBar(SnackBar(content: Text('Video Uploaded')));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }
    return Scaffold(
        key: _globalKey,
        body: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: new CameraPreview(controller)),
            Align(
              alignment: Alignment.bottomCenter,
              child: CountdownTimer(
                controller: _timerController,
                widgetBuilder: (_, CurrentRemainingTime time) {
                  return Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                          color: Color(0xffED553b), shape: BoxShape.circle),
                      child: Center(
                          child: Text(time != null ? '${time.sec}' : '0',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                // color: Colors.black,
                                fontFamily: 'Montserrat',
                              ))));
                },
              ),
            )
          ],
        ));
  }
}
