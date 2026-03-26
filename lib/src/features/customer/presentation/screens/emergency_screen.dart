import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../components/app_text_field.dart';
import '../../../../components/location_map_card.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/location_service.dart';
import '../../../../shared/maps/map_picker_screen.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../stores/emergency/emergency_cubit.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  LatLng? _selectedLocation;
  String? _selectedType;
  bool _loadingLocation = true;

  List<String> _types(BuildContext context) {
    return [
      context.tr('gasLeak'),
      context.tr('fireRisk'),
      context.tr('carbonMonoxide'),
      context.tr('equipmentDamage'),
      context.tr('other'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final result = await context.read<LocationService>().getCurrentLocation();

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      setState(() {
        _selectedLocation = result.location;
        _loadingLocation = false;
      });
      return;
    }

    setState(() {
      _loadingLocation = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr(result.errorKey!))),
    );
  }

  Future<void> _pickLocation() async {
    final location = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (location == null) {
      return;
    }

    setState(() {
      _selectedLocation = location;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmergencyCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      ),
      child: BlocConsumer<EmergencyCubit, EmergencyState>(
        listener: (context, state) {
          if (state is EmergencyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(state.messageKey))),
            );
          }

          if (state is EmergencySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('emergencySubmitted'))),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isSubmitting = state is EmergencySubmitting;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.tr('emergencyReport')),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: context.tr('emergencyType'),
                        ),
                        items: _types(context)
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('selectEmergencyType');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _descriptionController,
                        labelText: context.tr('description'),
                        maxLines: 4,
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'descriptionRequired',
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_loadingLocation)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        )
                      else ...[
                        LocationMapCard(
                          latitude: _selectedLocation?.latitude,
                          longitude: _selectedLocation?.longitude,
                          title: context.tr('yourLocation'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickLocation,
                          icon: const Icon(Icons.location_on_outlined),
                          label: Text(context.tr('changeLocation')),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: context.tr('sendEmergencyReport'),
                        isBusy: isSubmitting,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          if (_selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('locationRequired')),
                              ),
                            );
                            return;
                          }

                          context.read<EmergencyCubit>().submit(
                                type: _selectedType!,
                                description: _descriptionController.text,
                                latitude: _selectedLocation!.latitude,
                                longitude: _selectedLocation!.longitude,
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
