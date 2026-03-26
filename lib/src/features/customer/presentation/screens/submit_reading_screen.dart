import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../components/app_text_field.dart';
import '../../../../components/primary_button.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/firestore_service.dart';

class SubmitReadingScreen extends StatefulWidget {
  const SubmitReadingScreen({super.key});

  @override
  State<SubmitReadingScreen> createState() => _SubmitReadingScreenState();
}

class _SubmitReadingScreenState extends State<SubmitReadingScreen> {
  final _picker = ImagePicker();
  final _textRecognizer = TextRecognizer();
  final _readingController = TextEditingController();

  File? _imageFile;
  bool _processing = false;

  Future<void> _captureMeter() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _imageFile = File(image.path);
      _processing = true;
    });

    final inputImage = InputImage.fromFilePath(image.path);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final detectedNumbers = recognizedText.blocks
        .expand((block) => block.lines)
        .map((line) => line.text)
        .join()
        .replaceAll(RegExp(r'[^0-9]'), '');

    setState(() {
      _readingController.text = detectedNumbers;
      _processing = false;
    });
  }

  Future<void> _submit() async {
    final reading = int.tryParse(_readingController.text.trim());
    if (reading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('meterReadingRequired'))),
      );
      return;
    }

    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) {
      return;
    }

    setState(() {
      _processing = true;
    });

    try {
      await context.read<FirestoreService>().submitReading(
            userId: uid,
            reading: reading,
          );

      if (!mounted) return;

      setState(() {
        _processing = false;
        _readingController.clear();
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('readingSubmitted'))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('readingFailed'))),
      );
    }
  }

  @override
  void dispose() {
    _readingController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('submitReading')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('takeMeterPhoto'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _imageFile == null
                      ? Center(child: Text(context.tr('noPhotoTaken')))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: context.tr('captureMeter'),
                onPressed: _captureMeter,
              ),
              if (_processing)
                const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _readingController,
                labelText: context.tr('detectedReading'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: context.tr('submitReading'),
                isBusy: _processing,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
