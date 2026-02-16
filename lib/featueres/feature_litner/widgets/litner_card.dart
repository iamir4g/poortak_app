import 'package:flutter/material.dart';

class LitnerCard extends StatelessWidget {
  final LinearGradient gradient;
  final String icon;
  final String number;
  final String label;
  final String subLabel;
  final VoidCallback onTap;
  const LitnerCard({
    required this.gradient,
    required this.icon,
    required this.number,
    required this.label,
    required this.subLabel,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 359,
        height: 143,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            // Right: White circle with image
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: Container(
                width: 79,
                height: 79,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Center/Left: Texts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 16, left: 24, top: 32, bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          number,
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFF29303D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Color(0xFF29303D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subLabel,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF52617A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LitnerTodayCard extends StatelessWidget {
  final String number;
  final String label;
  final String buttonText;
  final String imageAsset;
  final VoidCallback onTap;
  const LitnerTodayCard({
    this.number = '۳',
    this.label = 'کارت های امروز',
    this.buttonText = 'شروع',
    this.imageAsset = 'assets/images/litner/flash-card.png',
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 359,
        height: 112,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5DB), Color(0xFFFEE8DB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            // Right: White circle with image
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: Container(
                width: 79,
                height: 79,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    imageAsset,
                    width: 42,
                    height: 41,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Center: Texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFF29303D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color(0xFF52617A),
                    ),
                  ),
                ],
              ),
            ),
            // Left: Button
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 8),
              child: Container(
                width: 105,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA73F),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontFamily: 'IRANSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
