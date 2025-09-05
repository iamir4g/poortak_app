import 'package:flutter/material.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/payment_history_screen.dart';
import 'package:poortak/locator.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/profile_screen";
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await prefsOperator.getLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
    print("token: \\${await prefsOperator.getAccessToken()}");
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: MyColors.background3,
      body: SafeArea(
        child: Stack(
          children: [
            // Left and right brand secondary strips
            Row(
              children: [
                // Left strip
                // Container(
                //   width: 10,
                //   height: double.infinity,
                //   color: MyColors.brandSecondary,
                // ),
                // Center area with curved white background
                Expanded(
                  child: Stack(
                    children: [
                      // Curved white background
                      ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          height: 300, //double.infinity - 500,
                          color: Colors.white,
                        ),
                      ),
                      // Content
                      Column(
                        children: [
                          const SizedBox(height: 24),
                          // Avatar
                          Center(
                            child: Container(
                              width: 94,
                              height: 94,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Color(0xFFE6EBF2), width: 5),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profile/finalProfile.png', // Replace with actual asset
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name
                          const Text(
                            'بهاره بیرامی',
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF3D495C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Mobile
                          const Text(
                            ' موبایل: ۰۹۱۹۹۵۵۲۲۲۰',
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Color(0xFF52617A),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 180,
                                height: 42,
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFE0E4EB), width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Custom edit icon - using a simple icon for now
                                      // You can replace this with the actual SVG from Figma
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFA3AFC2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ویرایش حساب',
                                        style: TextStyle(
                                          fontFamily: 'IRANSans',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                          color: Color(0xFF52617A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // const Spacer(),
                          const SizedBox(height: 80),
                          // Padding(
                          // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          // child:
                          Column(
                            children: [
                              _ProfileActionCard(
                                icon: Icons.star,
                                label: 'امتیازات',
                                onTap: () {},
                              ),
                              const SizedBox(height: 16),
                              _ProfileActionCard(
                                icon: Icons.favorite,
                                label: 'علاقه مندی ها',
                                onTap: () {},
                              ),
                              const SizedBox(height: 16),
                              _ProfileActionCard(
                                icon: Icons.history,
                                label: 'تاریخچه خرید',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PaymentHistoryScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right strip
                // Container(
                //   width: 20,
                //   height: double.infinity,
                //   color: MyColors.brandSecondary,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      width: 357.838,
      margin: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                Icon(icon, color: Color(0xFFFFB200), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xFF3D495C),
                      height: 1.375, // 22px line height for 16px font
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Start from top-left
    path.moveTo(0, 0);

    // Go to top-right
    path.lineTo(size.width, 0);

    // Go to bottom-right
    path.lineTo(size.width, size.height - 50);

    // Create the concave curve at the bottom
    path.quadraticBezierTo(
      size.width * 0.5, // Control point x (center)
      size.height + 30, // Control point y (below the bottom for concave effect)
      size.width * 0.2, // End point x (20% from left)
      size.height - 20, // End point y
    );

    // Continue the curve to the left
    path.quadraticBezierTo(
      size.width * 0.05, // Control point x (5% from left)
      size.height - 45, // Control point y
      0, // End point x (left edge)
      size.height - 50, // End point y
    );

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
