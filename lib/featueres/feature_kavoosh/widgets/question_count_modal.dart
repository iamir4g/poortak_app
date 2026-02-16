import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class QuestionCountModal extends StatefulWidget {
  final String title;
  final VoidCallback onStart;

  const QuestionCountModal({
    super.key,
    required this.title,
    required this.onStart,
  });

  @override
  State<QuestionCountModal> createState() => _QuestionCountModalState();
}

class _QuestionCountModalState extends State<QuestionCountModal> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF52617A)),
              ),
              const SizedBox(width: 40), // Spacer for centering if needed
            ],
          ),
          // Icon Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF4081), // Pinkish red background from design
            ),
            child: Center(
              child: Image.asset(
                'assets/images/kavoosh/khodsanji/reiazi_logo.png', // Placeholder, should be dynamic
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: MyTextStyle.textHeader16Bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Slider Section
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: MyColors.primary,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    thumbColor: MyColors.primary,
                    overlayColor: MyColors.primary.withValues(alpha: 0.2),
                    trackHeight: 4.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 20.0),
                  ),
                  child: Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 40,
                    divisions: 40,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('۰',
                          style: MyTextStyle.textMatn12Bold
                              .copyWith(color: MyColors.textSecondary)),
                      Text('۲۰',
                          style: MyTextStyle.textMatn12Bold
                              .copyWith(color: MyColors.textSecondary)),
                      Text('۴۰',
                          style: MyTextStyle.textMatn12Bold
                              .copyWith(color: MyColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: widget.onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F445A), // Dark button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                'بزن بریم!',
                style: TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
