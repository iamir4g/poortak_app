import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/featureMenu/data/models/faq_model.dart';
import 'package:poortak/featueres/featureMenu/presentation/bloc/faq_bloc/faq_bloc.dart';

class FAQScreen extends StatefulWidget {
  static const String routeName = "/faq";
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FaqBloc>().add(const GetFaqEvent());
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
            Expanded(
              child: BlocBuilder<FaqBloc, FaqState>(
                builder: (context, state) {
                  if (state is FaqLoading || state is FaqInitial) {
                    return const Center(child: DotLoadingWidget());
                  }

                  if (state is FaqError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.message,
                              style: MyTextStyle.textMatn14Bold.copyWith(
                                color: MyColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            TextButton(
                              onPressed: () {
                                context
                                    .read<FaqBloc>()
                                    .add(const GetFaqEvent());
                              },
                              child: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is FaqSuccess) {
                    return Column(
                      children: [
                        _buildCategoryFilters(
                          categories: state.categories,
                          selectedCategory: state.selectedCategory,
                          chipBorderColor: chipBorderColor,
                          inactiveChipBackground: inactiveChipBackground,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        ),
                        Expanded(
                          child: _buildFAQList(
                            items: state.filteredItems,
                            cardBackgroundColor: cardBackgroundColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
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
    required List<String> categories,
    required String? selectedCategory,
    required Color chipBorderColor,
    required Color inactiveChipBackground,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final chips = <String?>[null, ...categories];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Row(
          children: chips.map((category) {
            final isActive = selectedCategory == category;
            final label = category ?? 'همه ی بخش ها';
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: GestureDetector(
                onTap: () {
                  context.read<FaqBloc>().add(
                        SelectFaqCategoryEvent(category: category),
                      );
                },
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
                      label,
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
    required List<FAQItem> items,
    required Color cardBackgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'سوالی یافت نشد',
          style: MyTextStyle.textMatn14Bold.copyWith(
            color: secondaryTextColor,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final faqItem = items[index];
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
            onTap: () {
              context.read<FaqBloc>().add(
                    ToggleFaqExpansionEvent(id: faqItem.id),
                  );
            },
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
