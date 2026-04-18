import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const mapTilerApiKey = "tZ2o6lnybdlL9T3HqcRr";

class MapLocationPage extends StatelessWidget {
  final double lat;
  final double lon;
  final String title;

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

    return Scaffold(
      appBar: AppBar(title: Text("Location: $title")),
      body: FlutterMap(
        options: MapOptions(initialCenter: postLocation, initialZoom: 18),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$mapTilerApiKey',
            // userAgentPackageName: 'com.example.geo_snap',
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
