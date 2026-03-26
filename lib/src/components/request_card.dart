import 'package:flutter/material.dart';

import 'status_chip.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isEmergency,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String status;
  final bool isEmergency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isEmergency ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
              foregroundColor: isEmergency ? Colors.red : Colors.green,
              child: Icon(isEmergency ? Icons.warning_amber : Icons.build),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(status: status),
          ],
        ),
      ),
    );
  }
}
