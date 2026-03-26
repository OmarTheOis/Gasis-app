import 'package:flutter/material.dart';

import '../i18n/app_localizations.dart';
import '../utils/constants/app_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final String status;

  Color _color() {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _label(BuildContext context) {
    switch (status) {
      case 'completed':
        return context.tr('completed');
      case 'in_progress':
        return context.tr('inProgress');
      default:
        return context.tr('pending');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label(context),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
