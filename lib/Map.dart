import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  _onMapCreated(GoogleMapController controller) {
    _controller.complete( controller );
  }

  _showMarker( LatLng latLng ) {
    Marker marker = Marker(
        markerId: MarkerId(
            "marker-${latLng.latitude}-${latLng.longitude}"
        ),
      position: latLng,
      infoWindow: InfoWindow(
        title: "Marker"
      )
    );
    setState(() {
      _markers.add( marker );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Map"),),
      body: Container(
        child: GoogleMap(
          markers: _markers,
          mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
                  zoom: 18
            ),
          onMapCreated: _onMapCreated,
          onLongPress: _showMarker,
        ),
      ),
    );
  }
}
