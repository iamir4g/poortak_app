import 'package:flutter/material.dart';

class BookDetailsScreen extends StatefulWidget {
  static const String routeName = '/book-detail';
  final String title;

  const BookDetailsScreen({
    super.key,
    required this.title,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FE),
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
                  'کتاب آموزشی دبستان',
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
            const SizedBox(height: 24),
            // Book Image and Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/placeholder_book.png', // Needs a valid asset or network image
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF29303D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نسخه الکترونیکی',
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 14,
                      color: Color(0xFF9BA7C6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'قیمت:',
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF29303D),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '۷۵,۰۰۰ تومان',
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF29303D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFFF9F29),
                unselectedLabelColor: const Color(0xFF9BA7C6),
                indicatorColor: const Color(0xFFFF9F29),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontFamily: 'IRANSans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'درباره کالا'),
                  Tab(text: 'ویژگی های کالا'),
                ],
              ),
            ),
            
            // Tab Content
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildDetailRow('ناشر:', 'انتشارات تاجیک'),
                  _buildDetailRow('نویسنده:', 'پرویز تاجیک'),
                  _buildDetailRow('فرمت:', 'PDF'),
                  _buildDetailRow('حجم:', '۲۴ مگابایت'),
                  _buildDetailRow('تعداد صفحه:', '۱۰۵ صفحه'),
                  _buildDetailRow('تاریخ نشر:', '۱۴۰۱'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF9BA7C6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'خواندن نمونه',
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9BA7C6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A80F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'افزودن به سبد خرید',
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 14,
              color: Color(0xFF9BA7C6),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF52617A),
            ),
          ),
        ],
      ),
    );
  }
}
