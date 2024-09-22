import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  final LatLng? initialLocation;

  MapPage({Key? key, this.initialLocation}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;
  String? _selectedLocationName;
  LatLng? _selectedLocationCoords;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocationCoords = widget.initialLocation;
      _updateMarkerAndAddress(widget.initialLocation!);
    }
  }

  void _searchAndMarkLocation(String address) async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final LatLng latLng = LatLng(locations[0].latitude, locations[0].longitude);
        _updateMarkerAndAddress(latLng);
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _updateMarkerAndAddress(LatLng latLng) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: latLng,
        zoom: 15,
      ),
    ));
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: latLng,
      ));
      _selectedLocationCoords = latLng;
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      setState(() {
        _selectedLocationName = "${place.street}, ${place.locality}, ${place.country}";
        _textEditingController.text = _selectedLocationName!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'name': _selectedLocationName,
                'coords': _selectedLocationCoords,
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation ?? LatLng(22.316067318993472, 114.17829210040219),
                zoom: 20,
              ),
              onTap: (LatLng latLng) {
                _updateMarkerAndAddress(latLng);
              },
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