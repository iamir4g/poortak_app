import 'package:flutter/material.dart';
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

  const ReusableModal({
    Key? key,
    required this.title,
    required this.message,
    this.buttonText = 'متوجه شدم',
    required this.type,
    this.onButtonPressed,
    this.secondButtonText,
    this.onSecondButtonPressed,
    this.showSecondButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        height: 311,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon based on type
            _buildIcon(),

            const SizedBox(height: 20),

            // Title
            Container(
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

            // Message
            Container(
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

            // Buttons
            if (showSecondButton && secondButtonText != null)
              // Two buttons layout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // First button (primary)
                  Container(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          onButtonPressed ?? () => Navigator.of(context).pop(),
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

                  // Second button (secondary)
                  Container(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onSecondButtonPressed ??
                          () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side:
                            const BorderSide(color: MyColors.primary, width: 1),
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
              Container(
                width: 172,
                height: 64,
                child: ElevatedButton(
                  onPressed:
                      onButtonPressed ?? () => Navigator.of(context).pop(),
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
    );
  }
}
