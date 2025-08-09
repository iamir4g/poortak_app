import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KavooshMainScreen extends StatefulWidget {
  static const String routeName = '/kavoosh-main';
  const KavooshMainScreen({super.key});

  @override
  State<KavooshMainScreen> createState() => _KavooshMainScreenState();
}

class _KavooshMainScreenState extends State<KavooshMainScreen> {
  @override
  void initState() {
    super.initState();
    // Set status bar to light content
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F9FE), // Light blue background from Figma
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    // Educational Videos Card
                    _buildContentCard(
                      title: 'ویدئو های آموزشی',
                      subtitle: 'ویدئو های آموزشی برای پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFFFFDCC),
                        Color(0xFFFFF3D6),
                      ],
                      onTap: () {
                        // Handle video tap
                      },
                    ),

                    const SizedBox(height: 13),

                    // Audio Books Card
                    _buildContentCard(
                      title: 'کتاب های صوتی',
                      subtitle: 'کتاب های آموزشی صوتی برای پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFECE2FD),
                        Color(0xFFF6DDF8),
                      ],
                      onTap: () {
                        // Handle audio books tap
                      },
                    ),

                    const SizedBox(height: 13),

                    // E-Books Card
                    _buildContentCard(
                      title: 'کتاب الکترونیکی',
                      subtitle:
                          'کتاب های آموزشی الکترونیکی برای پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFFBEBDF),
                        Color(0xFFFFDBDB),
                      ],
                      onTap: () {
                        // Handle e-books tap
                      },
                    ),

                    const SizedBox(height: 13),

                    // Self-Assessment Card
                    _buildContentCard(
                      title: 'خود سنجی',
                      subtitle: 'آزمون دروس پایه های تحصیلی',
                      gradientColors: const [
                        Color(0xFFD9FFFA),
                        Color(0xFFD9FFEA),
                      ],
                      onTap: () {
                        // Handle self-assessment tap
                      },
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

  Widget _buildContentCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white,
            width: 5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F92A2BE),
              blurRadius: 13,
              offset: Offset(0, -7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Image.asset(
                    _getIconPathForTitle(title),
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29303D),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF52617A),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getIconPathForTitle(String title) {
    switch (title) {
      case 'ویدئو های آموزشی':
        return 'assets/images/kavoosh/videoIcon.png';
      case 'کتاب های صوتی':
        return 'assets/images/kavoosh/audioBookIcon.png';
      case 'کتاب الکترونیکی':
        return 'assets/images/kavoosh/ebookIcon.png';
      case 'خود سنجی':
        return 'assets/images/kavoosh/selfAssessmentIcon.png';
      default:
        return 'assets/images/kavoosh/videoIcon.png';
    }
  }
}
