import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/step_progress.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';

class LitnerWordBoxScreen extends StatefulWidget {
  static const routeName = '/litner_word_box';
  const LitnerWordBoxScreen({super.key});

  @override
  _LitnerWordBoxScreenState createState() => _LitnerWordBoxScreenState();
}

class _LitnerWordBoxScreenState extends State<LitnerWordBoxScreen> {
  int currentStep = 0;
  final int totalSteps = 5; // Example value, adjust as needed

  final String englishWord = 'Lunch';
  final String persianWord = 'ناهار';
  final FlipCardController _flipController = FlipCardController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Litner Word Box'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          StepProgress(
            currentIndex: currentStep,
            totalSteps: totalSteps,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: FlipCard(
                controller: _flipController,
                rotateSide: RotateSide.right,
                axis: FlipAxis.vertical,
                frontWidget: _buildFront(context),
                backWidget: _buildBack(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentStep > 0
                      ? () => setState(() => currentStep--)
                      : null,
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: currentStep < totalSteps - 1
                      ? () => setState(() => currentStep++)
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      width: 260,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconifyIcon(
                icon: "cuida:volume-2-outline",
                size: 28,
                color: const Color(0xFF3A465A),
              ),
              const SizedBox(width: 12),
              Text(
                englishWord,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF3A465A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 1,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFBFD6F6),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _flipController.flipcard(),
            child: const IconifyIcon(
              icon: "solar:smartphone-rotate-angle-outline",
              size: 32,
              color: Color(0xFF3A465A),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Container(
      width: 260,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconifyIcon(
                icon: "cuida:volume-2-outline",
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                englishWord,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 1,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            persianWord,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _flipController.flipcard(),
            child: const IconifyIcon(
              icon: "solar:smartphone-rotate-angle-outline",
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
