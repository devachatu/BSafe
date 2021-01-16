import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:login_ui/CameraScreen.dart';
import 'package:login_ui/HomePage.dart';
import 'package:path/path.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

List<String> files = [];

class MyAlerts extends StatefulWidget {
  MyAlerts({Key key, this.video, this.lat, this.long}) : super(key: key);
  final video;
  final long;
  final lat;

  @override
  _MyAlertsState createState() {
    return new _MyAlertsState();
  }
}

class _MyAlertsState extends State<MyAlerts> {
  // VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  VlcPlayerController controller;
  final double playerWidth = 640;
  final double playerHeight = 360;

  @override
  void initState() {
    super.initState();
    controller = new VlcPlayerController(
        // Start playing as soon as the video is loaded.
        onInit: () {
      controller.play();
    });
    print(widget.video);
    // _controller = VideoPlayerController.network(
    //   'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    // );
    // _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
                height: playerHeight,
                width: playerWidth,
                child: new VlcPlayer(
                  aspectRatio: 16 / 9,
                  url: widget.video,
                  controller: controller,
                  placeholder: Center(child: CircularProgressIndicator()),
                )),
            SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width * 0.8,
              child: GoogleMap(
                // onMapCreated: _onMapCreated,
                markers: {
                  Marker(
                      markerId: MarkerId('p1'),
                      position: LatLng(
                          double.parse(widget.lat), double.parse(widget.long)),
                      icon: BitmapDescriptor.defaultMarker),
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      double.parse(widget.lat), double.parse(widget.long)),
                  zoom: 20.0,
                ),
              ),
            )
          ]),
    );
  }
}
