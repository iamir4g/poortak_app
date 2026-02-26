import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/common/widgets/primaryButton.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/l10n/app_localizations.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_bloc.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_event.dart';
import 'package:poortak/featueres/feature_litner/presentation/bloc/litner_state.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_word_completed_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_word_box_screen.dart';
import 'package:poortak/featueres/feature_litner/screens/litner_words_inprogress_screen.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/locator.dart';
import '../widgets/litner_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/main.dart'; // For routeObserver

class LitnerMainScreen extends StatefulWidget {
  static const routeName = '/litner_main';

  const LitnerMainScreen({super.key});

  @override
  State<LitnerMainScreen> createState() => _LitnerMainScreenState();
}

class _LitnerMainScreenState extends State<LitnerMainScreen> with RouteAware {
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    context.read<LitnerBloc>().add(FetchOverviewLitnerEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    context.read<LitnerBloc>().add(FetchOverviewLitnerEvent());
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await prefsOperator.getLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            if (!isLoggedIn)
              Padding(
                padding: EdgeInsets.all(Dimens.medium),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(Dimens.small),
                      child: Text(
                        l10n!.you_are_not_logged_in_litner,
                        style: MyTextStyle.textCenter16,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PrimaryButton(
                      lable: l10n.login,
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.routeName);
                      },
                    ),
                  ],
                )),
              )
            else
              // Main content
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: Dimens.large),
                    // Cards
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimens.nw(20.0)),
                      child: BlocBuilder<LitnerBloc, LitnerState>(
                        builder: (context, state) {
                          int inProgress = 0;
                          int completed = 0;
                          int today = 0;

                          if (state is OverviewLitnerSuccess) {
                            inProgress =
                                state.overviewLitner.data.inProgressWordsCount;
                            completed =
                                state.overviewLitner.data.completedWordsCount;
                            today = state.overviewLitner.data.todayWordsCount;
                          }

                          return Column(
                            children: [
                              LitnerCard(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEED0F6),
                                    Color(0xFFF2E5FF)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                icon:
                                    'assets/images/litner/work-in-progress.png',
                                number: state is OverviewLitnerLoading
                                    ? '...'
                                    : inProgress.toString(),
                                label: 'کلمه',
                                subLabel: 'در حال یادگیری',
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      LitnerWordsInprogressScreen.routeName);
                                },
                              ),
                              SizedBox(height: Dimens.medium),
                              LitnerCard(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFECFDE2),
                                    Color(0xFFE1FCF2)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                icon: 'assets/images/litner/mortarboard.png',
                                number: completed.toString(),
                                label: 'کلمه',
                                subLabel: 'آموخته شده',
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      LitnerWordCompletedScreen.routeName);
                                },
                              ),
                              SizedBox(height: Dimens.medium),
                              LitnerTodayCard(
                                number: today.toString(),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, LitnerWordBoxScreen.routeName);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: Dimens.large),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
