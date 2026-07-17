import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapScreen extends StatefulWidget {
  const OpenStreetMapScreen({super.key});

  @override
  State<OpenStreetMapScreen> createState() =>
      _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  final MapController _mapController = MapController();

  static const LatLng _defaultLocation = LatLng(
    28.6139,
    77.2090,
  );

  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;

  bool _isLoadingLocation = false;
  bool _selectingPickup = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Please enable location services.',
          isError: true,
        );
        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showMessage(
          'Location permission was denied.',
          isError: true,
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is permanently denied. '
              'Please enable it from app settings.',
          isError: true,
        );

        await Geolocator.openAppSettings();
        return;
      }

      final Position position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _currentLocation = location;
        _pickupLocation ??= location;
      });

      _mapController.move(location, 15);
    } catch (error) {
      _showMessage(
        'Unable to get current location: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      if (_selectingPickup) {
        _pickupLocation = position;
        _selectingPickup = false;
      } else {
        _destinationLocation = position;
      }
    });
  }

  void _selectPickupMode() {
    setState(() {
      _selectingPickup = true;
    });

    _showMessage('Tap on the map to select pickup.');
  }

  void _selectDestinationMode() {
    setState(() {
      _selectingPickup = false;
    });

    _showMessage('Tap on the map to select destination.');
  }

  void _clearLocations() {
    setState(() {
      _pickupLocation = _currentLocation;
      _destinationLocation = null;
      _selectingPickup = true;
    });
  }

  void _confirmLocations() {
    if (_pickupLocation == null) {
      _showMessage(
        'Please select a pickup location.',
        isError: true,
      );
      return;
    }

    if (_destinationLocation == null) {
      _showMessage(
        'Please select a destination.',
        isError: true,
      );
      return;
    }

    Navigator.pop(context, {
      'pickupLatitude': _pickupLocation!.latitude,
      'pickupLongitude': _pickupLocation!.longitude,
      'destinationLatitude': _destinationLocation!.latitude,
      'destinationLongitude': _destinationLocation!.longitude,
    });
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];

    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 55,
          height: 55,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 34,
          ),
        ),
      );
    }

    if (_pickupLocation != null) {
      markers.add(
        Marker(
          point: _pickupLocation!,
          width: 65,
          height: 65,
          child: const Column(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFF5B4CF0),
                size: 42,
              ),
              Text(
                'Pickup',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_destinationLocation != null) {
      markers.add(
        Marker(
          point: _destinationLocation!,
          width: 75,
          height: 65,
          child: const Column(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.redAccent,
                size: 42,
              ),
              Text(
                'Destination',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    if (_pickupLocation == null ||
        _destinationLocation == null) {
      return [];
    }

    return [
      Polyline(
        points: [
          _pickupLocation!,
          _destinationLocation!,
        ],
        strokeWidth: 5,
        color: const Color(0xFF5B4CF0),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialLocation =
        _currentLocation ?? _defaultLocation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Ride Route',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _clearLocations,
            tooltip: 'Clear locations',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialLocation,
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                // Replace with your actual application identifier.
                userAgentPackageName:
                'com.example.ride_mate',
              ),

              PolylineLayer(
                polylines: _buildPolylines(),
              ),

              MarkerLayer(
                markers: _buildMarkers(),
              ),

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      _selectingPickup
                          ? Icons.radio_button_checked
                          : Icons.location_on,
                      color: _selectingPickup
                          ? const Color(0xFF5B4CF0)
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectingPickup
                            ? 'Tap the map to select pickup'
                            : 'Tap the map to select destination',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 185,
            child: FloatingActionButton.small(
              heroTag: 'currentLocation',
              onPressed: _isLoadingLocation
                  ? null
                  : _getCurrentLocation,
              child: _isLoadingLocation
                  ? const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectPickupMode,
                            icon: const Icon(
                              Icons.radio_button_checked,
                            ),
                            label: const Text('PICKUP'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDestinationMode,
                            icon: const Icon(
                              Icons.location_on,
                            ),
                            label: const Text('DESTINATION'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _confirmLocations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF5B4CF0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'CONFIRM ROUTE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}