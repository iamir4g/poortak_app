import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
        width: 350,
        height:
            (customImagePath != null || customLottiePath != null) ? 380 : 311,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2C2E3F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
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

                const SizedBox(height: 20),

                // Title
                Center(
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: MyColors.textMatn1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Message
                Center(
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'IRANSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF3D495C),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Buttons
                if (showSecondButton && secondButtonText != null)
                  // Two buttons layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // First button (primary)
                      SizedBox(
                        width: 140,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onButtonPressed ??
                              () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Second button (secondary)
                      SizedBox(
                        width: 140,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: onSecondButtonPressed ??
                              () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(
                                color: MyColors.primary, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            secondButtonText!,
                            style: const TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: MyColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // Single button layout
                  Center(
                    child: SizedBox(
                      width: 172,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: onButtonPressed ??
                            () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontFamily: 'IRANSans',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Close Button (X) - Top Left (optional)
            if (showCloseButton)
              Positioned(
                top: 12,
                left: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF323548)
                          : const Color(0xFFF6F9FE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
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
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top section with icon and text
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Column(
                children: [
                  // Success icon with gradient background
                  SizedBox(
                      width: 140,
                      height: 140,
                      // decoration: BoxDecoration(
                      //   gradient: const LinearGradient(
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.bottomRight,
                      //     colors: [
                      //       Color(0xFF4CAF50), // Green
                      //       Color(0xFF26A69A), // Teal
                      //     ],
                      //   ),
                      //   borderRadius: BorderRadius.circular(16),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: Colors.green.withOpacity(0.3),
                      //       blurRadius: 8,
                      //       offset: const Offset(0, 4),
                      //     ),
                      //   ],
                      // ),
                      child: Image.asset("assets/images/cart/tick_cart.png")),

                  SizedBox(),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'IRANSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 28,
                  )
                ],
              ),
            ),

            // Bottom section with buttons
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Primary button in light blue section
                  GestureDetector(
                    onTap: onButtonPressed ?? () => Navigator.of(context).pop(),
                    child: Container(
                      alignment: Alignment.center,
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F0FE), // Light blue background
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontFamily: 'IRANSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1A73E8), // Dark blue
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Secondary button in white section
                  if (showSecondButton && secondButtonText != null)
                    GestureDetector(
                        onTap: onSecondButtonPressed ??
                            () => Navigator.of(context).pop(),
                        child: Container(
                          alignment: Alignment.center,
                          height: 70,
                          decoration: BoxDecoration(),
                          child: Text(
                            secondButtonText!,
                            style: const TextStyle(
                              fontFamily: 'IRANSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: MyColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline,
            size: 40,
            color: MyColors.error,
          ),
        );
      case ModalType.info:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: MyColors.info.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline,
            size: 40,
            color: MyColors.info,
          ),
        );
      case ModalType.success:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: MyColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 40,
            color: MyColors.success,
          ),
        );
    }
  }

  Widget _buildCustomImage() {
    return Image.asset(
      customImagePath!,
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }

  Widget _buildCustomLottie() {
    return Lottie.asset(
      customLottiePath!,
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      repeat: false,
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

  // Convenience methods for different modal types
  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
    String? secondButtonText,
    VoidCallback? onSecondButtonPressed,
    bool showSecondButton = false,
    bool showCloseButton = false,
    String? customImagePath,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: ModalType.error,
      onButtonPressed: onButtonPressed,
      barrierDismissible: barrierDismissible,
      secondButtonText: secondButtonText,
      onSecondButtonPressed: onSecondButtonPressed,
      showSecondButton: showSecondButton,
      showCloseButton: showCloseButton,
      customImagePath: customImagePath,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
    VoidCallback? onButtonPressed,
    bool barrierDismissible = true,
    String? secondButtonText,
    VoidCallback? onSecondButtonPressed,
    bool showSecondButton = false,
    bool showCloseButton = false,
    String? customImagePath,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: ModalType.info,
      onButtonPressed: onButtonPressed,
      barrierDismissible: barrierDismissible,
      secondButtonText: secondButtonText,
      onSecondButtonPressed: onSecondButtonPressed,
      showSecondButton: showSecondButton,
      showCloseButton: showCloseButton,
      customImagePath: customImagePath,
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'متوجه شدم',
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
    show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: ModalType.success,
      onButtonPressed: onButtonPressed,
      barrierDismissible: barrierDismissible,
      secondButtonText: secondButtonText,
      onSecondButtonPressed: onSecondButtonPressed,
      showSecondButton: showSecondButton,
      showCloseButton: showCloseButton,
      customImagePath: customImagePath,
      customLottiePath: customLottiePath,
      cartSuccessStyle: cartSuccessStyle,
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
