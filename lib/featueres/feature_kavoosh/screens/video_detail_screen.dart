import 'package:flutter/material.dart';
import 'package:poortak/featueres/feature_kavoosh/widgets/session_item.dart';

class VideoDetailScreen extends StatefulWidget {
  static const String routeName = '/video-detail';
  final String title;

  const VideoDetailScreen({
    super.key,
    required this.title,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool _isDescriptionExpanded = false;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Video Player Placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.movie_creation_outlined,
                      color: Color(0xFF2196F3),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'برای تماشای ویدئو روی بخش مورد نظر\nکلیک کنید.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontSize: 14,
                      color: Color(0xFF52617A),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Teacher Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teacher Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          // child: Image.asset(...), 
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'نام استاد:',
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 12,
                                    color: Color(0xFF9BA7C6),
                                  ),
                                ),
                                Text(
                                  'فاطمه میرایی', // Mock data
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF29303D),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'قیمت دوره:',
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 12,
                                    color: Color(0xFF9BA7C6),
                                  ),
                                ),
                                Text(
                                  '۷۵,۰۰۰ تومان', // Mock data
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF29303D),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Expandable Description
                  if (_isDescriptionExpanded) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'درباره ی استاد:',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9BA7C6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تالیف کتاب کار ریاضی چهارم کلاغ سپید - ریاضی چهارم چهل قدم کلاغ سپید - کتاب فارسی ششم منتشران - موسسه المپیاد ریاضی - مدرس غیر انتفاعی',
                      style: TextStyle(
                        fontFamily: 'IRANSans',
                        fontSize: 12,
                        color: Color(0xFF52617A),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F9FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'مدت زمان کل این دوره:',
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontSize: 12,
                              color: Color(0xFF9BA7C6),
                            ),
                          ),
                          Text(
                            '۱۴ ساعت و ۲۰ دقیقه',
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF29303D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isDescriptionExpanded ? 'بستن اطلاعات' : 'اطلاعات دوره',
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9F29),
                          ),
                        ),
                        Icon(
                          _isDescriptionExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_left,
                          color: const Color(0xFFFF9F29),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sessions List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SessionItem(
                    title: 'جلسه صفر - پیش نمایش دوره',
                    isLocked: false, // Free
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه یک - حل مسئله - الگو یابی - شمارش...',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه دو - مرور فصل ۶',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  SessionItem(
                    title: 'جلسه سه - آمار و احتمال',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                   SessionItem(
                    title: 'جلسه چهار - احتمال',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                   SessionItem(
                    title: 'جلسه پنج - نمودار دایره ای',
                    isLocked: true,
                    isPlaying: false,
                    onTap: () {},
                  ),
                  // Add more items as needed
                ],
              ),
            ),
            
            const SizedBox(height: 80), // Space for bottom button
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Add to cart action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A80F0), // Blue button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'اضافه به سبد خرید',
              style: TextStyle(
                fontFamily: 'IRANSans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
