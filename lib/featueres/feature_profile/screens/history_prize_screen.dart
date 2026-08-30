import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/common/utils/date_util.dart';
import 'package:poortak/common/utils/digit_utils.dart';
import 'package:poortak/common/widgets/poortak_app_bar.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_profile/data/models/prize_history_model.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/prize_history_bloc/prize_history_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/prize_history_bloc/prize_history_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/user_points_total_bloc/user_points_total_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/user_points_total_bloc/user_points_total_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/user_points_total_bloc/user_points_total_state.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/prize_history_bloc/prize_history_state.dart';
import 'package:poortak/featueres/feature_profile/repositories/profile_repository.dart';
import 'package:poortak/featueres/feature_profile/widgets/prize_history_item.dart';
import 'package:poortak/featueres/feature_profile/widgets/date_separator.dart';
import 'package:poortak/locator.dart';

class HistoryPrizeScreen extends StatefulWidget {
  static const routeName = "/history_prize_screen";

  const HistoryPrizeScreen({super.key});

  @override
  State<HistoryPrizeScreen> createState() => _HistoryPrizeScreenState();
}

class _HistoryPrizeScreenState extends State<HistoryPrizeScreen> {
  late PrizeHistoryBloc _prizeHistoryBloc;

  @override
  void initState() {
    super.initState();
    _prizeHistoryBloc = PrizeHistoryBloc(
      repository: locator<ProfileRepository>(),
    );
    _prizeHistoryBloc.add(LoadPrizeHistoryEvent());
    locator<UserPointsTotalBloc>().add(LoadUserPointsTotalEvent());
  }

  @override
  void dispose() {
    _prizeHistoryBloc.close();
    super.dispose();
  }

  String _formatDateForDisplay(DateTime dateTime) {
    return DateUtil.toPersianMonthYear(dateTime);
  }

  List<PrizeHistoryGroup> _groupHistoryByDate(List<PrizeHistoryModel> items) {
    final Map<String, List<PrizeHistoryModel>> grouped = {};

    for (final item in items) {
      final dateKey = _formatDateForDisplay(item.createdAt);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) {
        final aParts = a.split(' ');
        final bParts = b.split(' ');
        if (aParts.length == 2 && bParts.length == 2) {
          final aYear = int.tryParse(aParts[1]) ?? 0;
          final bYear = int.tryParse(bParts[1]) ?? 0;
          if (aYear != bYear) return bYear.compareTo(aYear);

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

    return Scaffold(
      backgroundColor: isDarkMode ? MyColors.darkBackground : Colors.white,
      appBar: const PoortakAppBar(title: 'تاریخچه امتیاز'),
      body: SafeArea(
        top: false,
        child: BlocBuilder<UserPointsTotalBloc, UserPointsTotalState>(
          builder: (context, pointsState) {
            final totalAdded = pointsState is UserPointsTotalSuccess
                ? pointsState.data.added
                : null;

            return BlocProvider.value(
              value: _prizeHistoryBloc,
              child: BlocBuilder<PrizeHistoryBloc, PrizeHistoryState>(
                builder: (context, state) {
                  if (state is PrizeHistoryLoading ||
                      state is PrizeHistoryRefreshing) {
                    return Column(
                      children: [
                        _buildTotalPointsSection(isDarkMode, totalAdded),
                        const Expanded(
                            child: Center(child: CircularProgressIndicator())),
                      ],
                    );
                  }

                  if (state is PrizeHistoryError) {
                    return Column(
                      children: [
                        _buildTotalPointsSection(isDarkMode, totalAdded),
                        Expanded(child: _buildErrorState(state.message)),
                      ],
                    );
                  }

                  if (state is PrizeHistoryEmpty) {
                    return Column(
                      children: [
                        _buildTotalPointsSection(isDarkMode, totalAdded),
                        Expanded(child: _buildEmptyState(state.message)),
                      ],
                    );
                  }

                  if (state is PrizeHistorySuccess) {
                    final historyGroups =
                        _groupHistoryByDate(state.prizeHistoryResponse.data);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildTotalPointsSection(isDarkMode, totalAdded),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _prizeHistoryBloc.add(RefreshPrizeHistoryEvent());
                              locator<UserPointsTotalBloc>()
                                  .add(RefreshUserPointsTotalEvent());
                              await Future.wait([
                                _prizeHistoryBloc.stream.firstWhere(
                                  (s) =>
                                      s is PrizeHistorySuccess ||
                                      s is PrizeHistoryEmpty ||
                                      s is PrizeHistoryError,
                                ),
                                locator<UserPointsTotalBloc>().stream.firstWhere(
                                  (s) =>
                                      s is UserPointsTotalSuccess ||
                                      s is UserPointsTotalError,
                                ),
                              ]);
                            },
                            child: _buildHistoryList(historyGroups),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalPointsSection(bool isDarkMode, int? totalAmount) {
    return Container(
      height: 89.h,
      width: double.infinity,
      color: isDarkMode ? MyColors.darkBackground : const Color(0xFFFFF8E4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'جمع امتیاز ها:',
            style: MyTextStyle.textMatn16.copyWith(
              fontWeight: FontWeight.w500,
              color: isDarkMode ? MyColors.darkTextPrimary : Colors.black,
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            width: 88.w,
            height: 33.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDCB2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                totalAmount == null
                    ? '...'
                    : '${toPersianDigits('$totalAmount')} سکه',
                textAlign: TextAlign.center,
                style: MyTextStyle.textMatn16.copyWith(
                  color: const Color(0xFF29303D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              message,
              style: MyTextStyle.textMatn16.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? MyColors.darkTextPrimary
                    : MyColors.textMatn1,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              _prizeHistoryBloc.add(LoadPrizeHistoryEvent());
            },
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 80.h),
        Center(
          child: Text(
            message,
            style: MyTextStyle.textMatn16.copyWith(
              fontWeight: FontWeight.w300,
              color: Theme.of(context).brightness == Brightness.dark
                  ? MyColors.darkTextPrimary
                  : MyColors.textMatn1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<PrizeHistoryGroup> historyGroups) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 16.h),
      itemCount: historyGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = historyGroups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DateSeparator(date: group.date),
            ...group.items.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: PrizeHistoryItem(
                    title: item.displayTitle,
                    points: item.pointsDisplay,
                    isCompleted: true,
                  ),
                )),
            if (groupIndex < historyGroups.length - 1) SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}
