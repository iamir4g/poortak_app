import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_profile/data/models/prize_history_model.dart';
import 'package:poortak/featueres/feature_profile/widgets/prize_history_item.dart';
import 'package:poortak/featueres/feature_profile/widgets/date_separator.dart';

class HistoryPrizeScreen extends StatefulWidget {
  static const routeName = "/history_prize_screen";

  const HistoryPrizeScreen({super.key});

  @override
  State<HistoryPrizeScreen> createState() => _HistoryPrizeScreenState();
}

class _HistoryPrizeScreenState extends State<HistoryPrizeScreen> {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? MyColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Total Points Section
            _buildTotalPointsSection(isDarkMode),

            // History List
            Expanded(
              child: _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      height: 57,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(33.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'تاریخچه امتیاز',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? MyColors.darkTextPrimary
                  : const Color(0xFF3D495C),
            ),
            textAlign: TextAlign.center,
          ),

          // Back Button
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(left: 16),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_forward,
                color: isDarkMode
                    ? MyColors.darkTextPrimary
                    : const Color(0xFF3D495C),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPointsSection(bool isDarkMode) {
    return Container(
      height: 89,
      width: double.infinity,
      color: isDarkMode ? MyColors.darkBackground : const Color(0xFFFFF8E4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Total points text
          Text(
            'جمع امتیاز ها:',
            style: TextStyle(
              fontFamily: 'IRANSans',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? MyColors.darkTextPrimary : Colors.black,
            ),
          ),

          const SizedBox(width: 16),

          // Points container
          Container(
            width: 88,
            height: 33,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDCB2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '۱۸ سکه',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF29303D),
                  fontSize: 16,
                  fontFamily: 'IRANSans',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Sample data - in real app this would come from API/state management
    final List<PrizeHistoryGroup> historyGroups = [
      PrizeHistoryGroup(
        date: 'آذر ۱۴۰۳',
        items: [
          PrizeHistoryModel(
            id: '1',
            title: 'امتیاز روزانه',
            points: '۱ سکه',
            date: 'آذر ۱۴۰۳',
          ),
          PrizeHistoryModel(
            id: '2',
            title: 'دعوت کردن (پوریا) به اپلیکیشن',
            points: '۵ سکه',
            date: 'آذر ۱۴۰۳',
          ),
        ],
      ),
      PrizeHistoryGroup(
        date: 'آبان ۱۴۰۳',
        items: [
          PrizeHistoryModel(
            id: '3',
            title: 'خرید بسته ی کامل سیاره آی نو',
            points: '۵ سکه',
            date: 'آبان ۱۴۰۳',
          ),
          PrizeHistoryModel(
            id: '4',
            title: 'خرید (درس اول) سیاره آی نو',
            points: '۲ سکه',
            date: 'آبان ۱۴۰۳',
          ),
        ],
      ),
      PrizeHistoryGroup(
        date: 'مهر ۱۴۰۳',
        items: [
          PrizeHistoryModel(
            id: '5',
            title: 'امتیاز روزانه',
            points: '۱ سکه',
            date: 'مهر ۱۴۰۳',
          ),
          PrizeHistoryModel(
            id: '6',
            title: 'امتیاز روزانه',
            points: '۱ سکه',
            date: 'مهر ۱۴۰۳',
          ),
          PrizeHistoryModel(
            id: '7',
            title: 'عضویت در اپلیکیشن',
            points: '۵ سکه',
            date: 'مهر ۱۴۰۳',
          ),
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: historyGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = historyGroups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Date separator
            DateSeparator(date: group.date),

            // Items for this date
            ...group.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PrizeHistoryItem(
                    title: item.title,
                    points: item.points,
                    isCompleted: item.isCompleted,
                  ),
                )),

            // Add some spacing between groups
            if (groupIndex < historyGroups.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
