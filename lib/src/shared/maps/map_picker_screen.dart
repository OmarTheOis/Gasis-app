import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../components/primary_button.dart';
import '../../i18n/app_localizations.dart';
import '../../services/location_service.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    this.initialLocation,
  });

  final LatLng? initialLocation;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    if (widget.initialLocation != null) {
      setState(() {
        _selectedLocation = widget.initialLocation;
        _loading = false;
      });
      return;
    }

    final result = await context.read<LocationService>().getCurrentLocation();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr(result.errorKey!))),
      );
      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      _selectedLocation = result.location;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('pickLocation')),
        backgroundColor: theme.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _selectedLocation == null
              ? Center(child: Text(context.tr('currentLocationUnavailable')))
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation!,
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      onMapCreated: (controller) {
                        _controller = controller;
                      },
                      onTap: (location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('selected_location'),
                          position: _selectedLocation!,
                        ),
                      },
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: PrimaryButton(
                        label: context.tr('confirmLocation'),
                        onPressed: _selectedLocation == null
                            ? null
                            : () {
                                Navigator.of(context).pop(_selectedLocation);
                              },
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
