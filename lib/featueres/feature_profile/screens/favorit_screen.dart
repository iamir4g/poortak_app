import 'package:flutter/material.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class FavoritScreen extends StatefulWidget {
  static const routeName = "/favorit_screen";
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  // این متغیر برای نمایش حالت خالی یا پر استفاده می‌شود
  bool hasFavorites = false; // برای تست، true کنید تا حالت پر نمایش داده شود

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? MyColors.darkBackground : MyColors.background3,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Content
            Expanded(
              child: hasFavorites
                  ? _buildFavoritesList(isDarkMode)
                  : _buildEmptyState(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      height: 57,
      margin: const EdgeInsets.only(top: 22),
      child: Stack(
        children: [
          // Header Background
          Container(
            height: 57,
            decoration: BoxDecoration(
              color:
                  isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(33.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
          ),

          // Title
          Positioned(
            right: 32,
            top: 16,
            child: Text(
              'علاقه مندی ها',
              style: MyTextStyle.textHeader16Bold.copyWith(
                color: isDarkMode ? Colors.white : MyColors.textMatn1,
              ),
            ),
          ),

          // Back Button
          Positioned(
            left: 16,
            top: 11,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white : MyColors.textMatn1,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty State Image
          Transform.rotate(
            angle: 0.025, // تقریباً 1.435 درجه
            child: SizedBox(
              width: 110.7,
              height: 212.8,
              child: Image.asset(
                'assets/images/favorit/Delivery_Final.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 58),

          // Empty State Text
          Text(
            'هنوز چیزی اضافه نکردی!',
            style: MyTextStyle.textMatn16.copyWith(
              color: isDarkMode ? Colors.white : MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(17),
      itemCount: 5, // تعداد آیتم‌های نمونه
      itemBuilder: (context, index) {
        return _buildFavoriteItem(isDarkMode, index);
      },
    );
  }

  Widget _buildFavoriteItem(bool isDarkMode, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 144,
      decoration: BoxDecoration(
        color: isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Title
                  Text(
                    'درس اول آموزش زبان انگلیسی (سیاره آی نو)',
                    style: MyTextStyle.textMatn13.copyWith(
                      color: isDarkMode ? Colors.white : MyColors.textMatn1,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Play Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MyColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image Section
          Container(
            width: 110,
            height: 110,
            margin: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/favorit/Delivery_Final.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Favorite Button
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                // حذف از علاقه‌مندی‌ها
                setState(() {
                  // در اینجا باید آیتم از لیست حذف شود
                });
              },
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: MyColors.error,
                  borderRadius: BorderRadius.circular(8.5),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
