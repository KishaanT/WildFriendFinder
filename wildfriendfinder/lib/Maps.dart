import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class UserLocationPage extends StatefulWidget {
  final String userAddress;
  final String username;

  const UserLocationPage(
      {super.key, required this.userAddress, required this.username});

  @override
  State<UserLocationPage> createState() => _UserLocationPageState();
}

class _UserLocationPageState extends State<UserLocationPage> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  Set<Marker> markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCoordinates();
  }

  Future<void> getCoordinates() async {
    try {
      List<Location> locations = await locationFromAddress(widget.userAddress);
      if (locations.isNotEmpty) {
        setState(() {
          userLocation =
              LatLng(locations.first.latitude, locations.first.longitude);
          markers.add(
            Marker(
              markerId: MarkerId('userLocation'),
              position: userLocation!,
              infoWindow: InfoWindow(
                title: widget.username,
                snippet: widget.userAddress,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
            ),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Address not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting coordinates: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Location'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Go Back'),
                    ),
                  ],
                ))
              : GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: userLocation!, zoom: 15),
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
      floatingActionButton: userLocation != null
          ? Row(
          mainAxisAlignment: MainAxisAlignment.center, children: [
              FloatingActionButton(
                onPressed: () {
                  mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: userLocation!, zoom: 15),
                    ),
                  );
                },
                child: Icon(Icons.center_focus_strong, color: Colors.white,),
                backgroundColor: Colors.deepPurple,
              ),
              SizedBox(
                width: 10,
              ),
            FloatingActionButton(onPressed: (){
              showModalBottomSheet(context: context,
                  builder: (context)=> Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        Text('Owner: ${widget.username}'),
                        SizedBox(height: 5),
                        Text('Address: ${widget.userAddress}'),
                        SizedBox(height: 5),
                        Text(
                          'Coordinates: ${userLocation!.latitude.toStringAsFixed(6)}, ${userLocation!.longitude.toStringAsFixed(6)}',
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  )
              );
            },
              child: Icon(Icons.info, color: Colors.white,),
              backgroundColor: Colors.deepPurple,
            )
            ])
          : null,
    );
  }
}
