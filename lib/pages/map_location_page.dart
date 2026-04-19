/*
 Group 2
 Student names: Ka Lung Chan, Xuanyu Wang, Jaden Douglas, Nayeong Lim
 Studnet numbers: 9034150, 9020543, 9032089, 8943403
 Description: an applications that allows users to post, view, like blog posts with photos
 */
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const mapTilerApiKey =
    "tZ2o6lnybdlL9T3HqcRr"; //API key for map tiler, used to display the map in the app.

// The MapLocationPage widget displays a map centered on a specific location, marked with a pin.
class MapLocationPage extends StatelessWidget {
  final double lat;
  final double lon;
  final String title;

  // Constructor for the MapLocationPage widget.
  const MapLocationPage({
    super.key,
    required this.lat,
    required this.lon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng postLocation = LatLng(lat, lon);
    // final LatLng postLocation = LatLng(43.472285, -80.544857);

    // The Scaffold widget provides a basic structure for the page.
    return Scaffold(
      appBar: AppBar(title: Text("Location: $title")),
      body: FlutterMap(
        options: MapOptions(initialCenter: postLocation, initialZoom: 18),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$mapTilerApiKey', // Map tiler URL template for fetching map tiles, using the provided API key.
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: postLocation,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.pin_drop,
                  color: Colors.deepOrange,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
