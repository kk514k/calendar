// map_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;

  void _searchAndMarkLocation(String address) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final LatLng latLng = LatLng(locations[0].latitude, locations[0].longitude);
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15,
          ),
        ));

        setState(() {
          _markers.clear();
          _markers.add(Marker(
            markerId: MarkerId('searched_location'),
            position: latLng,
          ));
        });
      }
    } catch (e) {
      print('Error occurred: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps in Flutter'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MapContainer(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: _markers,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      labelText: 'Enter location to search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchAndMarkLocation(_textEditingController.text);
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(),
        ],
      ),
    );
  }
}

class MapContainer extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated;
  final Set<Marker> markers;

  const MapContainer({
    required this.onMapCreated,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: LatLng(22.316067318993472, 114.17829210040219),
        zoom: 20,
      ),
    );
  }
}