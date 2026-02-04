import 'package:flutter/material.dart';

class SessionItem extends StatelessWidget {
  final String title;
  final bool isLocked;
  final bool isPlaying;
  final VoidCallback onTap;

  const SessionItem({
    super.key,
    required this.title,
    this.isLocked = true,
    this.isPlaying = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isPlaying ? const Color(0xFFF9F6C6) : Colors.transparent, // Highlight if playing
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Lock/Status Icon (Right side in RTL)
            Icon(
              isLocked ? Icons.lock : Icons.play_circle_outline,
              color: isLocked ? Colors.amber : const Color(0xFF29303D),
              size: 20,
            ),
            
            const SizedBox(width: 12),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: 12,
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFF29303D),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Play Arrow Icon (Left side in RTL)
            if (!isLocked)
              const Icon(
                Icons.play_arrow,
                size: 16,
                color: Color(0xFF9BA7C6),
              ),
          ],
        ),
      ),
    );
  }
}
