import 'package:flutter/material.dart';

import '../../i18n/app_localizations.dart';
import 'input_sanitizer.dart';

class FormValidators {
  static String? requiredText(
    BuildContext context,
    String? value,
    String translationKey,
  ) {
    if (InputSanitizer.clean(value ?? '').isEmpty) {
      return context.tr(translationKey);
    }
    return null;
  }

  static String? email(BuildContext context, String? value) {
    final cleaned = InputSanitizer.clean(value ?? '');
    if (cleaned.isEmpty) {
      return context.tr('emailRequired');
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(cleaned)) {
      return context.tr('invalidEmail');
    }
    return null;
  }

  static String? strongPassword(BuildContext context, String? value) {
    final cleaned = InputSanitizer.clean(value ?? '');
    if (cleaned.isEmpty) {
      return context.tr('passwordRequired');
    }

    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$',
    );

    if (!passwordRegex.hasMatch(cleaned)) {
      return context.tr('passwordValidation');
    }

    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String? confirmValue,
    String originalPassword,
  ) {
    final cleaned = InputSanitizer.clean(confirmValue ?? '');
    if (cleaned.isEmpty) {
      return context.tr('confirmPasswordRequired');
    }

    if (cleaned != originalPassword) {
      return context.tr('passwordsDoNotMatch');
    }

    return null;
  }

  static String? cardNumber(BuildContext context, String? value) {
    final digits = (value ?? '').replaceAll(' ', '');
    if (digits.isEmpty) {
      return context.tr('cardNumberRequired');
    }
    if (digits.length != 16) {
      return context.tr('cardNumberInvalid');
    }
    return null;
  }

  static String? expiry(BuildContext context, String? value) {
    final cleaned = InputSanitizer.clean(value ?? '');
    if (cleaned.isEmpty) {
      return context.tr('expiryRequired');
    }

    final expiryRegex = RegExp(r'^\d{2}/\d{2}$');
    if (!expiryRegex.hasMatch(cleaned)) {
      return context.tr('expiryInvalid');
    }
    return null;
  }

  static String? cvv(BuildContext context, String? value) {
    final cleaned = InputSanitizer.clean(value ?? '');
    if (cleaned.isEmpty) {
      return context.tr('cvvRequired');
    }
    if (cleaned.length != 3) {
      return context.tr('cvvInvalid');
    }
    return null;
  }
}
