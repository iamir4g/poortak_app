import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';

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

    if (cartSuccessStyle) {
      return _buildCartSuccessModal(context, isDarkMode);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.9.sw,
        constraints: BoxConstraints(maxWidth: 350.w),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2E3F) : Colors.white,
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
                      width: 250.w,
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: MyColors.textMatn1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  // Message
                  Center(
                    child: Container(
                      width: 250.w,
                      margin: EdgeInsets.only(bottom: 30.h),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: const Color(0xFF3D495C),
                          height: 1.4,
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
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: onButtonPressed ??
                                    () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  buttonText,
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 10.w),

                          // Second button (secondary)
                          Expanded(
                            child: SizedBox(
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: onSecondButtonPressed ??
                                    () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: const BorderSide(
                                      color: MyColors.primary, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  secondButtonText!,
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.sp,
                                    color: MyColors.primary,
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
                        height: 64.h,
                        child: ElevatedButton(
                          onPressed: onButtonPressed ??
                              () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: Colors.white,
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
                      color: isDarkMode
                          ? const Color(0xFF323548)
                          : const Color(0xFFF6F9FE),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 0.9.sw,
        constraints: BoxConstraints(maxWidth: 350.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top section with icon and text
            Padding(
              padding: EdgeInsets.only(top: 30.h, left: 20.w, right: 20.w),
              child: Column(
                children: [
                  // Success icon with gradient background
                  SizedBox(
                      width: 140.w,
                      height: 140.h,
                      child: Image.asset("assets/images/cart/tick_cart.png")),

                  SizedBox(),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12.h),

                  // Message
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: Colors.black,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 28.h,
                  )
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
                  // Primary button in light blue section
                  GestureDetector(
                    onTap: onButtonPressed ?? () => Navigator.of(context).pop(),
                    child: Container(
                      alignment: Alignment.center,
                      height: 70.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F0FE), // Light blue background
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontFamily: 'IRANSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: Color(0xFF1A73E8), // Dark blue
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  // Secondary button in white section
                  if (showSecondButton && secondButtonText != null)
                    GestureDetector(
                        onTap: onSecondButtonPressed ??
                            () => Navigator.of(context).pop(),
                        child: Container(
                          alignment: Alignment.center,
                          height: 70.h,
                          decoration: BoxDecoration(),
                          child: Text(
                            secondButtonText!,
                            style: TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp,
                              color: Colors.black, // Dark gray
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )),
                ],
              ),
            ),
          ],
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
            color: MyColors.error.withOpacity(0.1),
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
            color: MyColors.info.withOpacity(0.1),
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
            color: MyColors.success.withOpacity(0.1),
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

  static void show({
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
    showDialog(
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
