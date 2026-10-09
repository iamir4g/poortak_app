import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/widgets/reusable_modal.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/featueres/feature_bookmarks/data/models/bookmark_models.dart';
import 'package:poortak/featueres/feature_bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'package:poortak/featueres/feature_profile/screens/login_screen.dart';
import 'package:poortak/locator.dart';

class BookmarkToggleButton extends StatelessWidget {
  final BookmarkType type;
  final String itemId;
  final Color? iconColor;
  final double iconSize;

  const BookmarkToggleButton({
    super.key,
    required this.type,
    required this.itemId,
    this.iconColor,
    this.iconSize = 24,
  });

  void _promptLogin(BuildContext context) {
    ReusableModal.show(
      context: context,
      title: '',
      message: 'لطفا ابتدا وارد حساب کاربری خود شوید',
      type: ModalType.info,
      buttonText: 'ورود به حساب کاربری',
      onButtonPressed: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, LoginScreen.routeName);
      },
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    if (itemId.isEmpty) return;

    if (!locator<PrefsOperator>().isLoggedIn()) {
      _promptLogin(context);
      return;
    }

    final cubit = context.read<BookmarkCubit>();
    final ok = await cubit.toggle(type: type, itemId: itemId);
    if (!context.mounted) return;

    if (!ok) {
      final code = cubit.state.actionErrorCode;
      final message = code == 'unauthorized'
          ? 'لطفا ابتدا وارد حساب کاربری خود شوید'
          : 'خطا در به‌روزرسانی علاقه‌مندی‌ها';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      cubit.clearActionError();
      if (code == 'unauthorized') {
        _promptLogin(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ??
        (isDark ? MyColors.darkTextPrimary : Colors.black);

    return BlocBuilder<BookmarkCubit, BookmarkState>(
      buildWhen: (prev, next) =>
          prev.isBookmarked(type, itemId) != next.isBookmarked(type, itemId),
      builder: (context, state) {
        final isBookmarked = state.isBookmarked(type, itemId);
        return IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: color,
            size: iconSize,
          ),
          onPressed: () => _onPressed(context),
        );
      },
    );
  }
}
