import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';

class ContestCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ContestCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 105,
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, 0.50),
                end: Alignment(1.00, 0.50),
                colors: [const Color(0xFFF1EFFF), const Color(0xFFF2F6FD)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Text content - positioned exactly like Figma
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'مسابقه پورتک',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color,
                                ),
                              ),
                              Text(
                                'در مسابقه ماهانه پورتک شرکت کنید و جایزه ببرید.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                              ),
                            ],
                          ))),
                  SizedBox(width: 16),
                  // Gift box icon container - positioned exactly like Figma
                  Container(
                    width: 77.5,
                    height: 79,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                        ),
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                        ),
                      ],
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF4A4D6B) // Dark icon background
                          : MyColors.background, // Light icon background
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 49,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.asset("assets/images/main/gift-box.png"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
