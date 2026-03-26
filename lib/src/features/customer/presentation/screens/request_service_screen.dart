import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../components/app_text_field.dart';
import '../../../../components/location_map_card.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../../shared/maps/map_picker_screen.dart';
import '../../../../utils/helpers/form_validators.dart';
import '../../stores/service_request/service_request_cubit.dart';

class RequestServiceScreen extends StatefulWidget {
  const RequestServiceScreen({super.key});

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedService;
  LatLng? _selectedLocation;

  List<String> _services(BuildContext context) {
    return [
      context.tr('newConnection'),
      context.tr('disconnection'),
      context.tr('reconnection'),
      context.tr('maintenance'),
      context.tr('inspection'),
      context.tr('meterReplacement'),
    ];
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _dateController.text =
          '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
    });
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
      if (_addressController.text.trim().isEmpty) {
        _addressController.text =
            '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceRequestCubit(
        authService: context.read<AuthService>(),
        firestoreService: context.read<FirestoreService>(),
      ),
      child: BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
        listener: (context, state) {
          if (state is ServiceRequestFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr(state.messageKey))),
            );
          }

          if (state is ServiceRequestSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('serviceRequestSubmitted'))),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ServiceRequestSubmitting;

          return Scaffold(
            appBar: AppBar(
              title: Text(context.tr('requestService')),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        decoration: InputDecoration(
                          labelText: context.tr('serviceType'),
                        ),
                        items: _services(context)
                            .map(
                              (service) => DropdownMenuItem(
                                value: service,
                                child: Text(service),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedService = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('selectServiceType');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _addressController,
                        labelText: context.tr('serviceAddress'),
                        hintText: context.tr('enterServiceAddress'),
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'addressRequired',
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _dateController,
                        labelText: context.tr('preferredDate'),
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (value) => FormValidators.requiredText(
                          context,
                          value,
                          'preferredDateRequired',
                        ),
                        suffixIcon: IconButton(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                        ),
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
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr('selectedLocation'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LocationMapCard(
                        latitude: _selectedLocation?.latitude,
                        longitude: _selectedLocation?.longitude,
                        title: context.tr('location'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickLocation,
                        icon: const Icon(Icons.location_on_outlined),
                        label: Text(context.tr('pickLocation')),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: context.tr('sendServiceRequest'),
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

                          context.read<ServiceRequestCubit>().submit(
                                type: _selectedService!,
                                description: _descriptionController.text,
                                address: _addressController.text,
                                preferredDate: _dateController.text,
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
