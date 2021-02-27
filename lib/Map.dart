import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  String tripId;
  Maps({ this.tripId });

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  CameraPosition _positionCamera = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 18);

  Firestore _db = Firestore.instance;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _addMarker(LatLng latLng) async {
    
    List<Placemark> listAddress = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if ( listAddress != null && listAddress.length > 0 ) {
      Placemark address = listAddress[0];
      String street = address.thoroughfare;

      Marker marker = Marker(
          markerId: MarkerId("marker-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: street));
      setState(() {
        _markers.add(marker);

        Map<String, dynamic> trip = new Map<String, dynamic>();
        trip["title"] = street;
        trip["latitude"] = latLng.latitude;
        trip["longitude"] = latLng.longitude;
        _db.collection("trips").add( trip );
      });
    }

  }

  _moveCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_positionCamera));
  }

  _addListenerLocation() {
    var geoLocator = Geolocator();
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high);
    geoLocator.getPositionStream(locationOptions).listen((Position position) {
      setState(() {
        _positionCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18
        );
        _moveCamera();
      });
    });
  }

  _getTripById(String tripId) async {

    if( tripId != null) {
      DocumentSnapshot documentSnapshot = await _db.collection("trips").document( tripId ).get();

      var data = documentSnapshot.data;

      String title = data["title"];
      LatLng latLng = LatLng(
          data["latitude"],
          data["longitude"]
      );

      setState(() {
        Marker marker = Marker(
            markerId: MarkerId("marker-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(title: title));
        _markers.add( marker );
        _positionCamera = CameraPosition(target: latLng, zoom: 18);
        _moveCamera();
      });
    } else {
      _addListenerLocation();
    }
  }

  @override
  void initState() {
    _getTripById( widget.tripId );
    //_addListenerLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
      ),
      body: Container(
        child: GoogleMap(
          markers: _markers,
          mapType: MapType.normal,
          initialCameraPosition: _positionCamera,
          onMapCreated: _onMapCreated,
          onLongPress: _addMarker,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
