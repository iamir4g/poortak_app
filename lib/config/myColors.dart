import 'package:flutter/material.dart';

class MyColors {
  // Primary Colors
  static const Color primary = Color(0xFFFFA73F); // Orange
  static const Color primaryTint1 = Color(0xFFFFBD70);
  static const Color primaryTint2 = Color(0xFFFFD5A3);
  static const Color primaryTint3 = Color(0xFFFFECD6);
  static const Color primaryTint4 = Color(0xFFFFF8F0);
  static const Color primaryTint5 = Color(0xFFF2F6FD);
  static const Color primaryShade1 = Color(0xFFFFA73F);
  static const Color primaryShade2 = Color(0xFFFF8E0A);
  static const Color primaryShade3 = Color(0xFFD67400);
  static const Color primaryShade4 = Color(0xFFA35800);
  static const Color primaryShade5 = Color(0xFF703D00);
  static const Color primaryShade6 = Color(0xFF3D2100);
  static const Color statusBarColor = Color(0x1AFFFFFF);

  static const Color secondary = Color(0xFF4281EC); // Blue
  static const Color secondaryTint1 = Color(0xFF75A1EB);
  static const Color secondaryTint2 = Color(0xFFA2BFF1);
  static const Color secondaryTint3 = Color(0xFFCEDEF8);
  static const Color secondaryTint4 = Color(0xFFF6F9FE);

  static const Color secondaryShade1 = Color(0xFF4A83E4);
  static const Color secondaryShade2 = Color(0xFF2065D9);
  static const Color secondaryShade3 = Color(0xFF1A50AD);
  static const Color secondaryShade4 = Color(0xFF133C81);
  static const Color secondaryShade5 = Color(0xFF0D2754);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color shoppingCartBackground = Color(0xFFF4F6FB);
  static const Color lightDarkBackground = Color(0xFF121212); // Dark background
  static const Color modalHeaderBackground = Color(0xFFF3F4F7);
  static const Color inputBorder = Color(0xFFD1D1D6);
  // Text Colors
  static const Color textBase = Color(0xFF14181F);
  static const Color text1 = Color(0xFF29303D);
  static const Color text2 = Color(0xFF3D495C);
  static const Color text3 = Color(0xFF52617A);
  static const Color text4 = Color(0xFF667999);
  static const Color text5 = Color(0xFF8594AD);
  static const Color text6 = Color(0xFFA3AFC2);
  static const Color text7 = Color(0xFFC2C9D6);
  static const Color gray = Color(0xFFE0E4EB);

  static const Color textPrimary = Color(0xFF14181F);
  static const Color textSecondary = Color(0xFF757575); // Grey
  static const Color textLight = Color(0xFFFFFFFF); // White
  static const Color textMatn1 = Color(0xFF363A53);
  static const Color textMatn2 = Color(0xFF212937);
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFE53935); // Red
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color info = Color(0xFF2196F3); // Light Blue

  static const Color infoBg = Color(0xFFFBF6FB);

  // Common UI Colors
  static const Color divider = Color(0xFFE0E0E0); // Light Grey
  static const Color cardBackground = Color(0xFFFAFAFA); // Very Light Grey
  static const Color cardBackground1 = Color(0xFFF5F7FA);
  static const Color shadow = Color(0x1F000000); // Black with opacity

  // Header shadow (Figma: x=0, y=1, blur=1, spread=0, #000000 5%)
  static const Color headerShadowColor = Color(0x0D000000);
  static const BoxShadow headerBoxShadow = BoxShadow(
    color: headerShadowColor,
    offset: Offset(0, 1),
    blurRadius: 1,
    spreadRadius: 0,
  );
  static const List<BoxShadow> headerShadows = [headerBoxShadow];

  static BoxDecoration headerDecoration({
    required Color backgroundColor,
    BorderRadius? borderRadius,
  }) =>
      BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: headerShadows,
      );

  // Brand Colors (you can customize these based on your brand)
  static const Color brandPrimary = primary;
  static const Color brandSecondary = secondary;

  static const Color background1 = Color(0xFFF2F5FA);
  static const Color background2 = Color(0xFFF3F5F7);
  static const Color background3 = Color(0xFFF6F9FE);
  static const Color background4 = Color(0xFFEFEFEF);
  static const Color background5 = Color(0xFF545664);
  static const Color contestCardGradientStart = Color(0xFFF2F0FF);
  static const Color contestCardGradientEnd = Color(0xFFF2F6FD);
  static const LinearGradient contestCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      contestCardGradientStart,
      contestCardGradientEnd,
    ],
  );

  // Dark Mode Colors
  static const Color darkBackground =
      Color(0xFF212332); // Primary dark background
  static const Color darkBackgroundSecondary =
      Color(0xFF2C2E3F); // Secondary dark background
  static const Color darkCardBackground =
      Color(0xFF3B3D54); // Card/component background
  static const Color darkBorder = Color(0xFF696E96); // Border/divider color

  // Dark Mode Text Colors
  static const Color darkTextPrimary =
      Color(0xFFF2F5FA); // Primary text in dark mode
  static const Color darkTextSecondary =
      Color(0xFFA3AFC2); // Secondary text in dark mode
  static const Color darkTextAccent =
      Color(0xFFF8A748); // Accent text (orange/yellow)

  // Dark Mode Status Colors
  static const Color darkError = Color(0xFFFF6969); // Error red
  static const Color darkErrorLight = Color(0xFFFF5454); // Light error red

  // Dark Mode Specific Colors
  static const Color darkMatn1 = Color(0xFF363A53); // Dark text color
  static const Color darkText1 = text1; // Dark text variant

  // Login (Dark Mode)
  static const Color loginBackgroundOverlayDark = Color(0x99000000);
  static const Color loginInputBackgroundDark = Color(0xFF282A39);
  static const Color loginIconColorDark = Color(0xFFD3D4DA);
  static const Color loginIconContainerDark = Color(0xFF545878);
  static const Color loginTextPrimaryDark = Color(0xFFFFFFFF);
  static const Color loginTextSecondaryDark = Color(0xFF838697);
  static const Color loginButtonText = Color(0xFF171926);
  static const Color termsBackgroundDark = Color(0xFF282A39);
  static const Color textInputBackgroundDark = Color(0xFF35374B);
  // Sayareh / reader screen gradients
  static const List<Color> sayarehGradientDarkColors = [
    profileBackgroundDark,
    darkBackground,
    profileBackgroundDark,
  ];
  static const List<Color> sayarehGradientLightColors = [
    Color(0xFFE8F0FC),
    Color(0xFFFCEBF1),
    Color(0xFFEFE8FC),
  ];
  static const List<double> sayarehGradientStops = [0.1, 0.54, 1.0];

  static const LinearGradient sayarehScreenGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: sayarehGradientDarkColors,
    stops: sayarehGradientStops,
  );

  static const LinearGradient sayarehScreenGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: sayarehGradientLightColors,
    stops: sayarehGradientStops,
  );

  // PDF reader controls
  static const Color pdfReaderControlsBackgroundLight = Color(0xFFF5F7FA);
  static const Color pdfReaderControlsBackgroundDark = darkBackgroundSecondary;
  static const Color pdfReaderInputBorderDark = darkBorder;
  static const Color pdfReaderInputFillDark = termsBackgroundDark;

  // Profile (Dark Mode)
  static const Color profileBackgroundDark = Color(0xFF171926);
  static const Color profileHeaderDark = Color(0xFF212332);
  static const Color profileTextPrimaryDark = loginTextPrimaryDark;
  static const Color profileAvatarBorderDark = Color(0xFF3A3C45);

  // Payment History
  static const Color paymentHistoryScreenHeaderDark =
      darkBackgroundSecondary; // #2C2E3F
  static const Color paymentHistoryCardDark = termsBackgroundDark; // #282A39
  static const Color paymentHistoryCardHeaderDark = Color(0xFF323548);
  static const Color paymentHistoryCardHeaderLight = Color(0xFFF9F9F9);
  static const Color paymentHistoryHeaderTitleLight = Color(0xFF29303D);
  static const Color paymentHistoryDetailValueLight = Color(0xFF494E6A);
  static const Color paymentHistoryDetailLabelLight = Color(0xFF717483);

  // Conversation (Dark Mode)
  static const Color conversationFirstPersonBubbleDark = Color(0xFF262556);
  static const Color conversationSecondPersonBubbleDark = Color(0xFF27221C);
  static const Color conversationScreenBackgroundLight = Color(0xFFFFFFF8);
  static const Color conversationBubbleLeftLight = Color(0xFFE1E0FA);
  static const Color conversationBubbleRightLight = Color(0xFFFFEFDB);
  static const Color conversationSideCircleLeftLight = Color(0xFF7C79EC);
  static const Color conversationSideCircleRightLight = Color(0xFFFFC785);
  static const Color conversationPlayPauseDarkPaused = Color(0xFF3B3E54);

  // Quiz
  static const Color quizAnswerDefaultLightBackground = background3;
  static const Color quizAnswerDefaultDarkBackground =
      darkBackgroundSecondary; // #2C2E3F
  static const Color quizAnswerSelectedBorder = primary;
  static const Color quizAnswerCorrectBackgroundLight = Color(0xFFEDFAEB);
  static const Color quizAnswerCorrectBorderLight = Color(0xFF6FC845);
  static const Color quizAnswerWrongBackgroundLight = Color(0xFFFDEFE8);
  static const Color quizAnswerWrongBorderLight = Color(0xFFE96217);
  static const Color quizAnswerCorrectBackgroundDark = Color(0xFF10160F);
  static const Color quizAnswerCorrectBorderDark = Color(0xFF68D451);
  static const Color quizAnswerCorrectTextDark = Color(0xFF6EC644);
  static const Color quizAnswerWrongBackgroundDark = Color(0xFF351705);
  static const Color quizAnswerWrongBorderDark = Color(0xFFE96217);
  static const Color quizAnswerWrongTextDark = Color(0xFFE96216);

  // Progress Bar Colors
  static const Color progressBarColor = Color(0xFF5E85F2);
  static const Color progressBarBackground = Color(0xFFE0E0E0);
  static const Color vocabularyProgressFill = Color(0xFFFFD099);
  static const Color lessonCardProgressLight = Color(0xFFE4EDFB);
  static const Color lessonCardProgressDark = Color(0xFF3B3E54);

  // Shopping / promo specific
  static const Color discountBackground = Color(0xFFFEF3E6);
  static const Color cartFooterBackground = Color(0xFFEFF1F4);

  // Cart dialog (Dark Mode)
  static const Color cartDialogBackgroundDark = darkBackgroundSecondary;
  static const Color cartTabBarBackgroundDark = termsBackgroundDark;
  static const Color cartTabSelectedDark = profileBackgroundDark;
  static const Color cartTabUnselectedTextDark = loginTextSecondaryDark;
  static const Color cartPriceCardDark = termsBackgroundDark;
  static const Color cartBundleSectionDark = darkBackground;
  static const Color cartItemCardDark = termsBackgroundDark;
  static const Color cartDiscountBackgroundDark = Color(0xFF3D2A1A);
  static const Color cartPayableBackgroundDark = darkBackgroundSecondary;
  static const Color cartFooterBackgroundDark = paymentHistoryCardHeaderDark;
  static const Color cartCoinBadgeDark = darkBackgroundSecondary;
  static const Color cartImageFrameDark = termsBackgroundDark;

  // New colors for AddWordBottomSheet
  static const Color inputBackground = Color(0xFFF7F7FB);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textCancelButton = text2;
  static const Color activeTabBackground = Color(0xFF363A53);
  static const Color inactiveTabBackground = Color(0xFF9498AC);
  static const Color dividerGray = gray;
  static const Color modalButtonPressedLight = Color(0xFFCEDEF8);
}
