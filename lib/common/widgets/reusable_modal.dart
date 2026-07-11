import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

enum ModalType {
  error,
  info,
  success,
}

class ReusableModal extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final ModalType type;
  final VoidCallback? onButtonPressed;

  // Optional second button
  final String? secondButtonText;
  final VoidCallback? onSecondButtonPressed;
  final bool showSecondButton;

  // Optional close button (X)
  final bool showCloseButton;

  // Optional custom image
  final String? customImagePath;
  final String? customLottiePath;

  // Special style for cart success modal
  final bool cartSuccessStyle;

  const ReusableModal({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'متوجه شدم',
    required this.type,
    this.onButtonPressed,
    this.secondButtonText,
    this.onSecondButtonPressed,
    this.showSecondButton = false,
    this.showCloseButton = false,
    this.customImagePath,
    this.customLottiePath,
    this.cartSuccessStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBackgroundColor = isDarkMode
        ? MyColors.darkBackgroundSecondary
        : Colors.white;
    final titleColor =
        isDarkMode ? MyColors.darkTextPrimary : MyColors.textMatn1;
    final messageColor =
        isDarkMode ? MyColors.darkTextSecondary : const Color(0xFF3D495C);
    final closeButtonBackground = isDarkMode
        ? MyColors.paymentHistoryCardHeaderDark
        : const Color(0xFFF6F9FE);

    if (cartSuccessStyle) {
      return _buildCartSuccessModal(context, isDarkMode);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.9.sw,
        constraints: BoxConstraints(maxWidth: 350.w),
        decoration: BoxDecoration(
          color: modalBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: Dimens.large),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon based on type or custom image
                  Center(
                    child: customLottiePath != null
                        ? _buildCustomLottie()
                        : customImagePath != null
                            ? _buildCustomImage()
                            : _buildIcon(),
                  ),

                  SizedBox(height: 20.h),

                  // Title
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 260.w),
                      padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        title,
                        style: MyTextStyle.textHeader16Bold.copyWith(
                          color: titleColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Message
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 270.w),
                      padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
                      margin: EdgeInsets.only(bottom: 30.h),
                      child: Text(
                        message,
                        style: MyTextStyle.textMatn14Bold.copyWith(
                          color: messageColor,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Buttons
                  if (showSecondButton && secondButtonText != null)
                    // Two buttons layout
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dimens.medium),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First button (primary)
                          Expanded(
                            child: SizedBox(
                              height: Dimens.buttonHeight,
                              child: ElevatedButton(
                                onPressed: onButtonPressed ??
                                    () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.primary,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    buttonText,
                                    maxLines: 1,
                                    style: MyTextStyle.textMatn14Bold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),

                          // Second button (secondary)
                          Expanded(
                            child: SizedBox(
                              height: Dimens.buttonHeight,
                              child: ElevatedButton(
                                onPressed: onSecondButtonPressed ??
                                    () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  side: BorderSide(
                                    color: isDarkMode
                                        ? MyColors.darkBorder
                                        : MyColors.primary,
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    secondButtonText!,
                                    maxLines: 1,
                                    style: MyTextStyle.textMatn14Bold.copyWith(
                                      color: isDarkMode
                                          ? MyColors.darkTextPrimary
                                          : MyColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Single button layout
                    Center(
                      child: SizedBox(
                        width: 172.w,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: onButtonPressed ??
                              () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: 0,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              buttonText,
                              maxLines: 1,
                              style: MyTextStyle.textMatn16Bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Close Button (X) - Top Left (optional)
            if (showCloseButton)
              Positioned(
                top: 12.h,
                left: 12.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: closeButtonBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20.w,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF3D495C),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSuccessModal(BuildContext context, bool isDarkMode) {
    final onPrimaryTap = onButtonPressed ?? () => Navigator.of(context).pop();
    final onSecondaryTap =
        onSecondButtonPressed ?? () => Navigator.of(context).pop();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.9.sw,
        constraints: BoxConstraints(maxWidth: 350.w),
        decoration: BoxDecoration(
          color: isDarkMode ? MyColors.darkBackgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? MyColors.darkBackgroundSecondary
                    : MyColors.modalHeaderBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              padding: EdgeInsets.only(top: 30.h, left: 20.w, right: 20.w),
              child: Column(
                children: [
                  SizedBox(
                    width: 140.w,
                    height: 140.h,
                    child: Lottie.asset(
                      customLottiePath ?? 'assets/images/cart/Tick Market.json',
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                  ),
                  Text(
                    title,
                    style: MyTextStyle.modalTitle18Medium.copyWith(
                      color: isDarkMode
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    message,
                    style: MyTextStyle.modalMessage14Medium.copyWith(
                      color: isDarkMode
                          ? MyColors.darkTextSecondary
                          : MyColors.text3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28.h),
                ],
              ),
            ),

            // Bottom section with buttons
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Column(
                children: [
                  _buildCartActionButton(
                    context: context,
                    isDarkMode: isDarkMode,
                    text: buttonText,
                    onTap: onPrimaryTap,
                    textStyle: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: const Color(0xFF1A73E8),
                    ),
                  ),
                  if (showSecondButton && secondButtonText != null) ...[
                    SizedBox(height: 10.h),
                    _buildCartActionButton(
                      context: context,
                      isDarkMode: isDarkMode,
                      text: secondButtonText!,
                      onTap: onSecondaryTap,
                      textStyle: TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        color: isDarkMode
                            ? MyColors.darkTextPrimary
                            : MyColors.textMatn1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartActionButton({
    required BuildContext context,
    required bool isDarkMode,
    required String text,
    required VoidCallback onTap,
    required TextStyle textStyle,
  }) {
    return SizedBox(
      height: 70.h,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.transparent,
          splashColor: isDarkMode
              ? Colors.transparent
              : MyColors.modalButtonPressedLight,
          highlightColor: isDarkMode
              ? Colors.transparent
              : MyColors.modalButtonPressedLight,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Text(
                text,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case ModalType.error:
        return Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: MyColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            size: 40.w,
            color: MyColors.error,
          ),
        );
      case ModalType.info:
        return Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: MyColors.info.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.info_outline,
            size: 40.w,
            color: MyColors.info,
          ),
        );
      case ModalType.success:
        return Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: MyColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 40.w,
            color: MyColors.success,
          ),
        );
    }
  }

  Widget _buildCustomImage() {
    return Image.asset(
      customImagePath!,
      width: 120.w,
      height: 120.h,
      fit: BoxFit.contain,
    );
  }

  Widget _buildCustomLottie() {
    return Lottie.asset(
      customLottiePath!,
      width: 150.w,
      height: 150.h,
      fit: BoxFit.contain,
      repeat: false,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
    VoidCallback? onButtonPressed,
    String? secondButtonText,
    VoidCallback? onSecondButtonPressed,
    bool showSecondButton = false,
    bool cartSuccessStyle = false,
    String? customLottiePath,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: ModalType.success,
      onButtonPressed: onButtonPressed,
      secondButtonText: secondButtonText,
      onSecondButtonPressed: onSecondButtonPressed,
      showSecondButton: showSecondButton,
      cartSuccessStyle: cartSuccessStyle,
      customLottiePath: customLottiePath,
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
    String? customImagePath,
    String? customLottiePath,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: ModalType.error,
      onButtonPressed: onButtonPressed,
      barrierDismissible: barrierDismissible,
      customImagePath: customImagePath,
      customLottiePath: customLottiePath,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
    VoidCallback? onButtonPressed,
    String? customLottiePath,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: ModalType.info,
      onButtonPressed: onButtonPressed,
      customLottiePath: customLottiePath,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
    required ModalType type,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
    String? secondButtonText,
    VoidCallback? onSecondButtonPressed,
    bool showSecondButton = false,
    bool showCloseButton = false,
    String? customImagePath,
    String? customLottiePath,
    bool cartSuccessStyle = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return ReusableModal(
          title: title,
          message: message,
          buttonText: buttonText,
          type: type,
          onButtonPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
          secondButtonText: secondButtonText,
          onSecondButtonPressed: onSecondButtonPressed,
          showSecondButton: showSecondButton,
          showCloseButton: showCloseButton,
          customImagePath: customImagePath,
          customLottiePath: customLottiePath,
          cartSuccessStyle: cartSuccessStyle,
        );
      },
    );
  }
}
