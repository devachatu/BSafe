import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/widgets.dart';
// import 'package:geolocator/geolocator.dart';

class PoliceStations extends StatefulWidget {
  PoliceStations({Key key}) : super(key: key);

  @override
  _PoliceStationsState createState() => _PoliceStationsState();
}

class _PoliceStationsState extends State<PoliceStations> {
  Set<Marker> _markers = {};
  LatLng _center;
  bool isLoading = false;
  LatLng _currentLocation;
  Position currentLocation;
  Completer<GoogleMapController> _controller = Completer();
  void initState() {
    super.initState();
    isLoading = false;
    getUserLocation();
  }

  Future<Position> locateUser() async {
    return Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getUserLocation() async {
    setState(() {
      isLoading = true;
    });

    currentLocation = await locateUser();
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);
    });
    setState(() {
      isLoading = false;
    });
    print('center $_center');
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _markers.addAll([
        Marker(
            markerId: MarkerId('p1'),
            position: LatLng(17.429855626234204, 78.43652165327988),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('p2'),
            position: LatLng(17.502569513460983, 78.31708085701307),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('p3'),
            infoWindow: InfoWindow(title: "Kukutpally Police Station"),
            position: LatLng(17.50488476496054, 78.39185273760285),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('p4'),
            position: LatLng(17.494697437698715, 78.41321613205707),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('p5'),
            position: LatLng(17.437730505611103, 78.40884634682781),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('Padaw police post'),
            infoWindow: InfoWindow(title: 'Padaw police post'),
            position: LatLng(29.17154, 75.7268),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('Sadar thana'),
            infoWindow: InfoWindow(title: 'Sadar thana'),
            position: LatLng(29.17959, 75.73100),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('Women police station'),
            infoWindow: InfoWindow(title: 'Women police station'),
            position: LatLng(29.17735, 75.73046),
            icon: BitmapDescriptor.defaultMarker),
        Marker(
            markerId: MarkerId('City police station'),
            infoWindow: InfoWindow(title: 'City police station'),
            position: LatLng(29.16659, 75.72287),
            icon: BitmapDescriptor.defaultMarker),
      ]);
    });
    _controller.complete(controller);

    // Position position = await Geolocator()
    //     .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    // _controller.animateCamera(CameraUpdate.newCameraPosition(
    //     CameraPosition(target: LatLng(position.latitude, position.longitude))));
    // GeolocationStatus geolocationStatus =
    //     await Geolocator().checkGeolocationPermissionStatus();
    // _location.onLocationChanged.listen((event) {
    //   _controller.animateCamera(CameraUpdate.newCameraPosition(
    //       CameraPosition(target: LatLng(event.latitude, event.longitude))));
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoading
          ? CircularProgressIndicator()
          : GoogleMap(
              onMapCreated: _onMapCreated,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
            ),
    );
  }
}
