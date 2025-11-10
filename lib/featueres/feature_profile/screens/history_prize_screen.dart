import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_profile/data/models/prize_history_model.dart';
import 'package:poortak/featueres/feature_profile/widgets/prize_history_item.dart';
import 'package:poortak/featueres/feature_profile/widgets/date_separator.dart';
import 'package:poortak/common/utils/date_util.dart';

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
      SystemUiOverlayStyle(
        statusBarColor: MyColors.primary,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  /// Helper method to format date for display
  String _formatDateForDisplay(DateTime dateTime) {
    return DateUtil.toPersianMonthYear(dateTime);
  }

  /// Helper method to group history items by date
  List<PrizeHistoryGroup> _groupHistoryByDate(List<PrizeHistoryModel> items) {
    final Map<String, List<PrizeHistoryModel>> grouped = {};

    for (final item in items) {
      final dateKey = _formatDateForDisplay(item.createdAt);
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) {
        // Simple sorting by year and month
        final aParts = a.split(' ');
        final bParts = b.split(' ');
        if (aParts.length == 2 && bParts.length == 2) {
          final aYear = int.tryParse(aParts[1]) ?? 0;
          final bYear = int.tryParse(bParts[1]) ?? 0;
          if (aYear != bYear) return bYear.compareTo(aYear);

          // Compare months using DateUtil
          final aMonthIndex = DateUtil.persianMonths.indexOf(aParts[0]);
          final bMonthIndex = DateUtil.persianMonths.indexOf(bParts[0]);
          return bMonthIndex.compareTo(aMonthIndex);
        }
        return b.compareTo(a);
      });

    return sortedDates
        .map((date) => PrizeHistoryGroup(
              date: date,
              items: grouped[date]!,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Sample data - in real app this would come from API/state management
    final sampleResponse = PrizeHistoryResponse(
      ok: true,
      meta: {},
      data: [
        PrizeHistoryModel(
          id: "dfbdad42-e930-42d4-8833-bfd553430d7a",
          amount: 4,
          remainingAmount: 4,
          description: "",
          type: "همینجوری",
          userId: "ddda7ab9-c2b9-4abf-99cc-95eb51f15f9b",
          createdAt: DateTime.parse("2025-10-11T17:38:32.093Z"),
          updatedAt: DateTime.parse("2025-10-11T17:38:32.093Z"),
        ),
        PrizeHistoryModel(
          id: "e713a2a3-baf6-4471-ad2b-a66d5ff6e7cf",
          amount: 1,
          remainingAmount: 1,
          description: "",
          type: "پسر خوبی بوده",
          userId: "ddda7ab9-c2b9-4abf-99cc-95eb51f15f9b",
          createdAt: DateTime.parse("2025-10-06T21:00:41.418Z"),
          updatedAt: DateTime.parse("2025-10-06T21:00:41.418Z"),
        ),
        PrizeHistoryModel(
          id: "63c44cde-b191-497e-9d01-886b4cd350d8",
          amount: 3,
          remainingAmount: 3,
          description: "",
          type: "لاگین کرده",
          userId: "ddda7ab9-c2b9-4abf-99cc-95eb51f15f9b",
          createdAt: DateTime.parse("2025-10-06T21:00:24.589Z"),
          updatedAt: DateTime.parse("2025-10-06T21:00:24.589Z"),
        ),
      ],
    );

    final totalAmount = sampleResponse.totalAmount;
    final historyGroups = _groupHistoryByDate(sampleResponse.data);

    return Scaffold(
      backgroundColor: isDarkMode ? MyColors.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(isDarkMode),

            // Total Points Section
            _buildTotalPointsSection(isDarkMode, totalAmount),

            // History List
            Expanded(
              child: _buildHistoryList(historyGroups),
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

  Widget _buildTotalPointsSection(bool isDarkMode, int totalAmount) {
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
                '$totalAmount سکه',
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

  Widget _buildHistoryList(List<PrizeHistoryGroup> historyGroups) {
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
                    title: item.type,
                    points: item.pointsDisplay,
                    isCompleted: true,
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
