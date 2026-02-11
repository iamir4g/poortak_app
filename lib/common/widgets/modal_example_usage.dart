import 'package:flutter/material.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';

/// Example usage of ReusableModal
/// This file demonstrates how to use the ReusableModal component
/// You can delete this file after understanding the usage

class ModalExampleUsage extends StatelessWidget {
  const ModalExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modal Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Modal Example
            ElevatedButton(
              onPressed: () {
                ReusableModal.showError(
                  context: context,
                  title: 'خطا در ارسال',
                  message: 'کد ارسال شده به شماره موبایل خود را وارد کنید!',
                  buttonText: 'تلاش مجدد',
                  onButtonPressed: () {
                    Navigator.of(context).pop();
                    // Add your custom logic here
                    print('Error modal button pressed');
                  },
                );
              },
              child: const Text('نمایش مدال خطا'),
            ),

            const SizedBox(height: 20),

            // Info Modal Example
            ElevatedButton(
              onPressed: () {
                ReusableModal.showInfo(
                  context: context,
                  title: 'اطلاعات مهم',
                  message:
                      'این یک پیام اطلاعاتی است که باید به کاربر نمایش داده شود.',
                  buttonText: 'متوجه شدم',
                );
              },
              child: const Text('نمایش مدال اطلاعات'),
            ),

            const SizedBox(height: 20),

            // Success Modal Example
            ElevatedButton(
              onPressed: () {
                ReusableModal.showSuccess(
                  context: context,
                  title: 'عملیات موفق',
                  message: 'اطلاعات شما با موفقیت ذخیره شد.',
                  buttonText: 'بسیار خوب',
                  onButtonPressed: () {
                    Navigator.of(context).pop();
                    // Add your custom logic here
                    print('Success modal button pressed');
                  },
                );
              },
              child: const Text('نمایش مدال موفقیت'),
            ),

            const SizedBox(height: 20),

            // Custom Modal Example
            ElevatedButton(
              onPressed: () {
                ReusableModal.show(
                  context: context,
                  title: 'مدال سفارشی',
                  message: 'این یک مدال سفارشی با تنظیمات خاص است.',
                  buttonText: 'تایید',
                  type: ModalType.info,
                  barrierDismissible:
                      false, // User cannot dismiss by tapping outside
                  onButtonPressed: () {
                    Navigator.of(context).pop();
                    // Add your custom logic here
                    print('Custom modal button pressed');
                  },
                );
              },
              child: const Text('نمایش مدال سفارشی'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Usage Examples:
/// 
/// 1. Simple Error Modal:
/// ```dart
/// ReusableModal.showError(
///   context: context,
///   title: 'خطا',
///   message: 'پیام خطا',
/// );
/// ```
/// 
/// 2. Info Modal with Custom Button:
/// ```dart
/// ReusableModal.showInfo(
///   context: context,
///   title: 'اطلاعات',
///   message: 'پیام اطلاعاتی',
///   buttonText: 'باشه',
///   onButtonPressed: () {
///     Navigator.of(context).pop();
///     // Your custom logic
///   },
/// );
/// ```
/// 
/// 3. Success Modal:
/// ```dart
/// ReusableModal.showSuccess(
///   context: context,
///   title: 'موفقیت',
///   message: 'عملیات با موفقیت انجام شد',
/// );
/// ```
/// 
/// 4. Custom Modal:
/// ```dart
/// ReusableModal.show(
///   context: context,
///   title: 'عنوان',
///   message: 'پیام',
///   type: ModalType.error, // or ModalType.info, ModalType.success
///   buttonText: 'دکمه سفارشی',
///   barrierDismissible: false, // Optional: prevent dismissing by tapping outside
///   onButtonPressed: () {
///     // Custom action
///   },
/// );
/// ```
