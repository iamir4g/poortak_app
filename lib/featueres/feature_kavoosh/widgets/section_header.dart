import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAllTap;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF29303D),
            ),
          ),
          TextButton(
            onPressed: onSeeAllTap,
            child: const Text(
              'همه',
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF52617A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
