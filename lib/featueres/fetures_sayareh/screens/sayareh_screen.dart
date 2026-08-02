import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/iknow_access_bloc/iknow_access_bloc.dart';
import 'package:poortak/common/widgets/dot_loading_widget.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/fetures_sayareh/presentation/bloc/sayareh_bloc/sayareh_cubit.dart';
import 'package:poortak/featueres/feature_match/screens/main_match_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_bloc.dart';
import 'package:poortak/featueres/feature_shopping_cart/presentation/bloc/shopping_cart_event.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/contest_card.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/all_courses_progress_model.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/sayareh_home_model.dart';
import 'package:poortak/featueres/fetures_sayareh/screens/lesson_screen.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/dialog_cart.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_books_row.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_bundle_promo.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_episode_card.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_hero_card.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_home_header.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_roadmap.dart';
import 'package:poortak/featueres/fetures_sayareh/widgets/sayareh_section_header.dart';
import 'package:poortak/locator.dart';
import 'package:poortak/common/utils/prefs_operator.dart';

class SayarehScreen extends StatefulWidget {
  static const routeName = "/sayareh_screen";
  const SayarehScreen({super.key});

  @override
  State<SayarehScreen> createState() => _SayarehScreenState();
}

class _SayarehScreenState extends State<SayarehScreen> {
  static const _collapsedEpisodeCount = 3;
  bool _episodesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessBloc = locator<IknowAccessBloc>();
      accessBloc.add(FetchIknowAccessEvent(forceRefresh: true));
    });
  }

  CourseProgressItem? _progressFor(
    SayarehDataCompleted completed,
    Lesson item,
  ) {
    if (completed.progressData == null) return null;
    try {
      return completed.progressData!.data
          .firstWhere((element) => element.iKnowCourseId == item.id);
    } catch (_) {
      return null;
    }
  }

  double _averageProgress(CourseProgressItem? progress) {
    if (progress == null) return 0;
    return (progress.vocabulary + progress.conversation + progress.quiz) / 3;
  }

  ({Lesson lesson, int index, double average})? _continueTarget(
    SayarehDataCompleted completed,
    IknowAccessBloc accessBloc,
  ) {
    final lessons = completed.data.data;
    if (lessons.isEmpty) return null;

    for (var i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final avg = _averageProgress(_progressFor(completed, lesson));
      final purchased = accessBloc.hasCourseAccess(lesson.id);
      final locked = i == 0
          ? false
          : !purchased && !lesson.isDemo && lesson.trailerVideo.isEmpty;
      if (!locked && avg < 100) {
        return (lesson: lesson, index: i, average: avg);
      }
    }

    final first = lessons.first;
    return (
      lesson: first,
      index: 0,
      average: _averageProgress(_progressFor(completed, first)),
    );
  }

  void _openLesson(
    BuildContext context, {
    required Lesson lesson,
    required int index,
    required bool purchased,
  }) {
    Navigator.pushNamed(context, LessonScreen.routeName, arguments: {
      'index': index,
      'title': lesson.name,
      'lessonId': lesson.id,
      'purchased': purchased,
    });
  }

  BoxDecoration _screenDecoration(bool isDark) {
    return BoxDecoration(
      gradient: isDark
          ? MyColors.sayarehScreenGradientDark
          : MyColors.sayarehHomeScreenGradient,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = SayarehCubit(sayarehRepository: locator());
            cubit.callSayarehDataEvent();
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final bloc = ShoppingCartBloc(repository: locator());
            bloc.add(GetCartEvent());
            return bloc;
          },
        ),
        BlocProvider.value(
          value: locator<IknowAccessBloc>(),
        ),
      ],
      child: BlocBuilder<IknowAccessBloc, IknowAccessState>(
        buildWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType ||
            (current is IknowAccessCompleted &&
                previous is IknowAccessCompleted &&
                previous.data != current.data),
        builder: (context, accessState) {
          final accessBloc = context.read<IknowAccessBloc>();
          return BlocBuilder<SayarehCubit, SayarehState>(
            buildWhen: (previous, current) {
              if (previous.sayarehDataStatus == current.sayarehDataStatus) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state.sayarehDataStatus is SayarehDataLoading) {
                return Container(
                  decoration: _screenDecoration(isDark),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SayarehHomeHeader(),
                        Expanded(
                          child: Center(child: DotLoadingWidget(size: 100.r)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.sayarehDataStatus is SayarehDataCompleted) {
                final completed =
                    state.sayarehDataStatus as SayarehDataCompleted;
                final lessons = completed.data.data;
                final books = completed.bookListData.data ?? [];
                final continueTarget = _continueTarget(completed, accessBloc);
                final visibleCount = _episodesExpanded
                    ? lessons.length
                    : lessons.length.clamp(0, _collapsedEpisodeCount);
                final overallProgress = continueTarget?.average ?? 0;

                return Container(
                  decoration: _screenDecoration(isDark),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const SayarehHomeHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: Column(
                              children: [
                                SayarehHeroCard(
                                  lessonTitle: continueTarget?.lesson.name,
                                  overallProgress: overallProgress,
                                  onContinueTap: continueTarget == null
                                      ? null
                                      : () {
                                          final lesson = continueTarget.lesson;
                                          final purchased = accessBloc
                                              .hasCourseAccess(lesson.id);
                                          final index = continueTarget.index;
                                          final locked = index == 0
                                              ? false
                                              : !purchased &&
                                                  !lesson.isDemo &&
                                                  lesson.trailerVideo.isEmpty;
                                          if (locked) {
                                            showDialog(
                                              context: context,
                                              builder: (_) => DialogCart(
                                                item: lesson,
                                                summaryData:
                                                    completed.summaryData,
                                              ),
                                            );
                                            return;
                                          }
                                          _openLesson(
                                            context,
                                            lesson: lesson,
                                            index: index,
                                            purchased: purchased,
                                          );
                                        },
                                ),
                                SizedBox(height: 16.h),
                                const SayarehRoadmap(),
                                SizedBox(height: 22.h),
                                SayarehSectionHeader(
                                  title: 'قسمت‌های داستان',
                                  onActionTap: () {
                                    setState(() => _episodesExpanded = true);
                                  },
                                ),
                                SizedBox(height: 12.h),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: visibleCount,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: 10.h),
                                  itemBuilder: (context, index) {
                                    final item = lessons[index];
                                    return SayarehEpisodeCard(
                                      item: item,
                                      index: index,
                                      purchased:
                                          accessBloc.hasCourseAccess(item.id),
                                      progress:
                                          _progressFor(completed, item),
                                      summaryData: completed.summaryData,
                                    );
                                  },
                                ),
                                if (!_episodesExpanded &&
                                    lessons.length > _collapsedEpisodeCount) ...[
                                  SizedBox(height: 14.h),
                                  Center(
                                    child: _MoreEpisodesButton(
                                      onTap: () {
                                        setState(
                                            () => _episodesExpanded = true);
                                      },
                                    ),
                                  ),
                                ],
                                SizedBox(height: 24.h),
                                SayarehSectionHeader(
                                  title: 'کتاب‌های سیاره آی نو',
                                  leading: Icon(
                                    Icons.menu_book_rounded,
                                    size: 18.r,
                                    color: isDark
                                        ? MyColors.darkTextAccent
                                        : MyColors.sayarehHomePurple,
                                  ),
                                  onActionTap: () {},
                                ),
                                SizedBox(height: 12.h),
                                SayarehBooksRow(books: books),
                                SizedBox(height: 20.h),
                                SayarehBundlePromo(
                                  onTap: () {
                                    if (lessons.isEmpty) return;
                                    showDialog(
                                      context: context,
                                      builder: (_) => DialogCart(
                                        item: lessons.first,
                                        summaryData: completed.summaryData,
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16.h),
                                ContestCard(
                                  onTap: () {
                                    if (locator<PrefsOperator>().isLoggedIn()) {
                                      Navigator.pushNamed(
                                        context,
                                        MainMatchScreen.routeName,
                                      );
                                    } else {
                                      ReusableModal.show(
                                        context: context,
                                        title: '',
                                        message:
                                            'لطفا ابتدا وارد حساب کاربری خود شوید',
                                        type: ModalType.info,
                                        buttonText: 'ورود',
                                        onButtonPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.pushNamed(
                                            context,
                                            LoginScreen.routeName,
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 24.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.sayarehDataStatus is SayarehDataError) {
                final SayarehDataError sayarehDataError =
                    state.sayarehDataStatus as SayarehDataError;

                return Container(
                  decoration: _screenDecoration(isDark),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SayarehHomeHeader(),
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sayarehDataError.errorMessage,
                                  style: MyTextStyle.body16For(context),
                                ),
                                SizedBox(height: 10.h),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyColors.sayarehHomePurple,
                                  ),
                                  onPressed: () {
                                    BlocProvider.of<SayarehCubit>(context)
                                        .callSayarehDataEvent();
                                  },
                                  child: const Text('تلاش دوباره'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Container();
            },
          );
        },
      ),
    );
  }
}

class _MoreEpisodesButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreEpisodesButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          width: 105.w,
          height: 33.h,
          decoration: BoxDecoration(
            color: isDark
                ? MyColors.darkCardBackground
                : MyColors.sayarehHomeCardBg,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'بیشتر',
                style: MyTextStyle.sayarehHomeMoreButton.copyWith(
                  color: isDark ? MyColors.darkTextPrimary : MyColors.text2,
                ),
              ),
              SizedBox(width: 4.w),
              SvgPicture.asset(
                'assets/images/sayareh_home/chevron_more.svg',
                width: 10.r,
                height: 10.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
