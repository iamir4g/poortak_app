import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/detailed_course_card.dart';
import 'package:poortak/featueres/feature_kavoosh/screens/book_details_screen.dart';

class CourseListScreen extends StatefulWidget {
  static const String routeName = '/course-list';
  final String title;
  final String? type;

  const CourseListScreen({
    super.key,
    required this.title,
    this.type,
  });

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'همه',
    'ریاضی',
    'علوم تجربی',
    'زبان فارسی',
    'قرآن',
    'هدیه ها'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FE), // Light background color
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
                Text(
                  widget.title,
                  style: const TextStyle(
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
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF9F29) // Orange
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF9BA7C6),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // List of Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: 10,
              itemBuilder: (context, index) {
                // Mock data
                final colors = [
                  const Color(0xFFFBEBDF), // Light orange
                  const Color(0xFFE3F2FD), // Light blue
                  const Color(0xFFF3E5F5), // Light purple
                  const Color(0xFFE8F5E9), // Light green
                ];
                
                return DetailedCourseCard(
                  title: 'ریاضی سوم دبستان',
                  author: 'سمانه مراقی',
                  date: '۵ ماه پیش',
                  isPurchased: index % 2 == 0, // Alternate purchased status
                  backgroundColor: colors[index % colors.length],
                  onTap: widget.type == 'book'
                      ? () {
                          Navigator.pushNamed(
                            context,
                            BookDetailsScreen.routeName,
                            arguments: {'title': 'ریاضی سوم دبستان'},
                          );
                        }
                      : null,
                  // imagePath: 'assets/images/placeholder_book.png',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
