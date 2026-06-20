import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class ReferralCodeCard extends StatefulWidget {
  final ValueChanged<String>? onSubmit;

  const ReferralCodeCard({
    super.key,
    this.onSubmit,
  });

  @override
  State<ReferralCodeCard> createState() => _ReferralCodeCardState();
}

class _ReferralCodeCardState extends State<ReferralCodeCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _ensureVisible();
      }
    });
  }

  void _ensureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.25,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
      );
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
        _ensureVisible();
      });
    } else {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSubmit = _controller.text.trim().isNotEmpty;

    final titleStyle = MyTextStyle.textMatn14Bold.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.0,
      color: isDark ? MyColors.darkTextPrimary : MyColors.textMatn1,
    );

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: Dimens.nw(360.0)),
        height: Dimens.nh(_isExpanded ? 140.0 : 72.0),
        padding: EdgeInsets.all(Dimens.medium),
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
              onTap: _toggleExpanded,
              child: SizedBox(
                height: Dimens.nh(40),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text('کد معرف', style: titleStyle),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: SvgPicture.asset(
                        'assets/images/icons/iconamoon--arrow-left-2-duotone.svg',
                        width: Dimens.nr(22),
                        height: Dimens.nr(22),
                        colorFilter: ColorFilter.mode(
                          isDark ? Colors.white : MyColors.text2,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              SizedBox(height: Dimens.nh(14)),
              Center(
                child: SizedBox(
                  width: Dimens.nw(306),
                  height: Dimens.nh(45),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: MyTextStyle.referralCodeInput14Medium.copyWith(
                      color: isDark
                          ? MyColors.darkTextPrimary
                          : MyColors.textMatn1,
                    ),
                    onTap: _ensureVisible,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'کد معرف را وارد کنید',
                      hintStyle: MyTextStyle.textMatn14Bold.copyWith(
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? MyColors.darkTextSecondary
                            : MyColors.text6,
                        height: 1.0,
                      ),
                      contentPadding: EdgeInsetsDirectional.only(
                        start: Dimens.medium,
                        top: Dimens.nh(12),
                        bottom: Dimens.nh(12),
                        end: Dimens.nw(100),
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: Dimens.nw(85) + Dimens.nw(16),
                        minHeight: Dimens.nh(38),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: Dimens.nw(8),
                          end: Dimens.nw(8),
                          top: Dimens.nh(3.5),
                          bottom: Dimens.nh(3.5),
                        ),
                        child: SizedBox(
                          width: Dimens.nw(85),
                          height: Dimens.nh(38),
                          child: ElevatedButton(
                            onPressed: canSubmit
                                ? () {
                                    final code = _controller.text.trim();
                                    widget.onSubmit?.call(code);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canSubmit
                                  ? MyColors.primary
                                  : const Color(0xFFE5E5EA),
                              foregroundColor: canSubmit
                                  ? Colors.white
                                  : (isDark
                                      ? MyColors.darkTextSecondary
                                      : MyColors.text4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimens.nr(7)),
                              ),
                            ),
                            child: Text(
                              'ثبت کد',
                              style: MyTextStyle.textMatn12W700.copyWith(
                                color: canSubmit
                                    ? Colors.white
                                    : (isDark
                                        ? MyColors.darkTextSecondary
                                        : MyColors.text4),
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimens.nr(10)),
                        borderSide: const BorderSide(
                          width: 1,
                          color: MyColors.inputBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimens.nr(10)),
                        borderSide: const BorderSide(
                          width: 1,
                          color: MyColors.inputBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimens.nr(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: MyColors.inputBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
