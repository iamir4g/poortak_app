import 'package:flutter/material.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
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

  void _logout() async {
    await prefsOperator.logout();
    if (mounted) {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar with three-dot menu
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(33.5),
                  bottomRight: Radius.circular(33.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // Placeholder for symmetry
                  const Text(
                    'پروفایل',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF3D495C),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF3D495C)),
                    onSelected: (value) {
                      if (value == 'logout') _logout();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('خروج از ناحیه کاربری'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Avatar
            Center(
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFFE6EBF2), width: 5),
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
                    'assets/images/profile_avatar.png', // Replace with actual asset
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
                fontSize: 10,
                color: Color(0xFF52617A),
              ),
            ),
            const SizedBox(height: 32),
            // Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
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
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Edit Account Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Color(0xFFA3AFC2)),
                  label: const Text(
                    'ویرایش حساب',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Color(0xFF52617A),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E4EB), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 84,
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
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
