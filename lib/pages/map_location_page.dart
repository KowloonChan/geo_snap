import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationPage extends StatelessWidget {
  final double lat;
  final double lon;
  final String title;

  const MapLocationPage({super.key, required this.lat, required this.lon, required this.title});

  @override
  Widget build(BuildContext context) {
    final LatLng postLocation = LatLng(lat, lon);

    return Scaffold(
      appBar: AppBar(title: Text("Location: $title")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: postLocation,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('postLoc'),
            position: postLocation,
            infoWindow: InfoWindow(title: title),
          ),
        },
      ),
    );
  }
}