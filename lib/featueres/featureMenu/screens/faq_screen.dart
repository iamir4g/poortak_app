import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/featureMenu/models/faq_model.dart';

class FAQScreen extends StatefulWidget {
  static const String routeName = "/faq";
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  FAQCategory _selectedCategory = FAQCategory.all;
  final List<FAQItem> _faqItems = [
    FAQItem(
      id: '1',
      question: 'بهترین ترتیب برای مطالعه هر بخش چیست؟',
      answer:
          'برای بهترین نتیجه، ابتدا مفاهیم پایه را مطالعه کنید، سپس به سراغ تمرینات بروید و در نهایت آزمون‌ها را انجام دهید.',
      category: FAQCategory.lessons,
    ),
    FAQItem(
      id: '2',
      question: 'آیا می توان درس را دوباره مرور کرد؟',
      answer:
          'بله، شما می‌توانید هر درس را چندین بار مرور کنید تا کاملاً بر آن مسلط شوید.',
      category: FAQCategory.lessons,
    ),
    FAQItem(
      id: '3',
      question: 'چگونه می‌توانم درس‌ها را خریداری کنم؟',
      answer:
          'برای خرید درس‌ها، به بخش فروشگاه بروید، درس مورد نظر را انتخاب کرده و با روش‌های مختلف پرداخت خریداری کنید.',
      category: FAQCategory.payment,
    ),
    FAQItem(
      id: '4',
      question: 'چرا برخی از کتاب‌های کاوش قفل هستند؟',
      answer:
          'این کتاب‌ها باید خریداری شوند. پس از خرید، قفل آن‌ها باز می‌شود و می‌توانید مطالعه کنید.',
      category: FAQCategory.payment,
    ),
    FAQItem(
      id: '5',
      question: 'امتیازات من کجا نمایش داده می‌شود؟',
      answer: 'امتیازات شما در پروفایل شخصی و بخش پیشرفت قابل مشاهده است.',
      category: FAQCategory.general,
    ),
    FAQItem(
      id: '6',
      question: 'آیا می‌توانم از امتیازاتم برای خرید استفاده کنم؟',
      answer:
          'بله، امتیازات شما می‌تواند برای تخفیف در خرید درس‌های جدید استفاده شود.',
      category: FAQCategory.payment,
    ),
    FAQItem(
      id: '7',
      question: 'چگونه با پشتیبانی تماس بگیرم؟',
      answer:
          'از طریق بخش تماس با ما در تنظیمات یا ایمیل پشتیبانی می‌توانید با ما در ارتباط باشید.',
      category: FAQCategory.general,
    ),
    FAQItem(
      id: '8',
      question: 'زمان پاسخگویی پشتیبانی چقدر است؟',
      answer:
          'تیم پشتیبانی ما در کمتر از 24 ساعت به درخواست‌های شما پاسخ می‌دهد.',
      category: FAQCategory.general,
    ),
  ];

  List<FAQItem> get _filteredFAQItems {
    if (_selectedCategory == FAQCategory.all) {
      return _faqItems;
    }
    return _faqItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  void _toggleFAQExpansion(String id) {
    setState(() {
      for (int i = 0; i < _faqItems.length; i++) {
        if (_faqItems[i].id == id) {
          _faqItems[i] = _faqItems[i].copyWith(
            isExpanded: !_faqItems[i].isExpanded,
          );
        } else {
          _faqItems[i] = _faqItems[i].copyWith(isExpanded: false);
        }
      }
    });
  }

  void _selectCategory(FAQCategory category) {
    setState(() {
      _selectedCategory = category;
      // Close all expanded items when changing category
      for (int i = 0; i < _faqItems.length; i++) {
        _faqItems[i] = _faqItems[i].copyWith(isExpanded: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? MyColors.darkBackground : MyColors.background;
    final cardBackgroundColor =
        isDark ? MyColors.darkCardBackground : const Color(0xFFFBFBFF);
    final primaryTextColor =
        isDark ? MyColors.darkTextPrimary : MyColors.textMatn1;
    final secondaryTextColor =
        isDark ? MyColors.darkTextSecondary : MyColors.text3;
    final headerBackgroundColor =
        isDark ? MyColors.darkCardBackground : MyColors.background;
    final chipBorderColor =
        isDark ? MyColors.darkBorder : const Color(0xFFD9D9D9);
    final inactiveChipBackground =
        isDark ? MyColors.darkBackgroundSecondary : MyColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(headerBackgroundColor, primaryTextColor),
            _buildCategoryFilters(
              chipBorderColor: chipBorderColor,
              inactiveChipBackground: inactiveChipBackground,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),
            Expanded(
              child: _buildFAQList(
                cardBackgroundColor: cardBackgroundColor,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color headerBackgroundColor, Color primaryTextColor) {
    return Container(
      height: 57.h,
      decoration: BoxDecoration(
        color: headerBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(33.5.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 1.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'سوالات رایج',
                style: MyTextStyle.textHeader16Bold.copyWith(
                  color: primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_forward,
              color: primaryTextColor,
              size: 24.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters({
    required Color chipBorderColor,
    required Color inactiveChipBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Row(
          children: FAQCategory.values.map((category) {
            final isActive = _selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => _selectCategory(category),
                child: Container(
                  height: 33.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: isActive ? MyColors.primary : inactiveChipBackground,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isActive ? MyColors.primary : chipBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category.displayName,
                      style: MyTextStyle.textMatn12W500.copyWith(
                        color: isActive
                            ? MyColors.background
                            : secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFAQList({
    required Color cardBackgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      itemCount: _filteredFAQItems.length,
      itemBuilder: (context, index) {
        final faqItem = _filteredFAQItems[index];
        return _buildFAQCard(
          faqItem,
          cardBackgroundColor: cardBackgroundColor,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
        );
      },
    );
  }

  Widget _buildFAQCard(
    FAQItem faqItem, {
    required Color cardBackgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: faqItem.isExpanded
            ? Border.all(color: MyColors.secondary, width: 1)
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleFAQExpansion(faqItem.id),
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      faqItem.question,
                      style: MyTextStyle.textMatn14Bold.copyWith(
                        fontWeight: faqItem.isExpanded
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: faqItem.isExpanded
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? MyColors.darkTextPrimary
                                : MyColors.textMatn2)
                            : primaryTextColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: Transform.rotate(
                      angle: faqItem.isExpanded ? 6.2 : 1.5,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: primaryTextColor,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (faqItem.isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
              child: Text(
                faqItem.answer,
                style: MyTextStyle.textMatn12W300.copyWith(
                  color: secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
