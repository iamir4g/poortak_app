import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/section_header.dart';

class EducationalVideosScreen extends StatefulWidget {
  static const String routeName = '/educational-videos';

  const EducationalVideosScreen({super.key});

  @override
  State<EducationalVideosScreen> createState() =>
      _EducationalVideosScreenState();
}

class _EducationalVideosScreenState extends State<EducationalVideosScreen> {
  int _selectedTabIndex = 0; // 0 for Courses, 1 for Shorts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(57),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 32, 0),
            height: 57,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(33.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ویدئو های آموزشی',
                  style: TextStyle(
                    fontFamily: 'IRANSans',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29303D),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF29303D),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Slider Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F6C6), // Light yellow placeholder
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0), // Figma might show different
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: const Center(
                  // child: Text('Slider Placeholder'),
                  ),
            ),

            // Custom Tabs
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabItem(0, 'دوره ها', Icons.play_circle_outline),
                  const SizedBox(width: 24),
                  _buildTabItem(1, 'کوتاه آموزشی', Icons.movie_outlined),
                ],
              ),
            ),
            // Divider line for tabs
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.grey.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          color: _selectedTabIndex == 0
                              ? Colors.orange
                              : Colors.transparent)),
                  Expanded(
                      child: Container(
                          color: _selectedTabIndex == 1
                              ? Colors.orange
                              : Colors.transparent)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content Sections
            if (_selectedTabIndex == 0) ...[
              _buildSection('پایه اول دبستان'),
              _buildSection('پایه دوم دبستان'),
              _buildSection('پایه سوم دبستان'),
              _buildSection('پایه چهارم دبستان'),
            ] else ...[
              const SizedBox(
                height: 200,
                child: Center(child: Text('محتوای کوتاه آموزشی')),
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: isSelected ? Colors.orange : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () {
            // Navigate to all courses for this section
          },
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              // Alternating background colors for demo
              final colors = [
                const Color(0xFFFBEBDF), // Light orange
                const Color(0xFFE3F2FD), // Light blue
                const Color(0xFFF3E5F5), // Light purple
              ];
              return CourseCard(
                title: 'ریاضی',
                backgroundColor: colors[index % colors.length],
                // imagePath: 'assets/images/placeholder_book.png',
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
