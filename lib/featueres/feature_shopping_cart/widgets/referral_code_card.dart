import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

/// Thrown when referral submission is cancelled (e.g. login prompt).
class ReferralCodeSubmitAborted implements Exception {}

enum _ReferralFeedback { none, success, error }

class ReferralCodeCard extends StatefulWidget {
  final Future<void> Function(String code)? onSubmit;

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
  bool _isSubmitting = false;
  _ReferralFeedback _feedback = _ReferralFeedback.none;

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

  void _onTextChanged(String _) {
    setState(() {
      if (_feedback != _ReferralFeedback.none) {
        _feedback = _ReferralFeedback.none;
      }
    });
  }

  Future<void> _handleSubmit() async {
    final code = _controller.text.trim();
    if (code.isEmpty ||
        _isSubmitting ||
        widget.onSubmit == null ||
        _feedback != _ReferralFeedback.none) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit!(code);
      if (!mounted) return;
      setState(() {
        _feedback = _ReferralFeedback.success;
        _isSubmitting = false;
      });
      _focusNode.unfocus();
    } on ReferralCodeSubmitAborted {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feedback = _ReferralFeedback.error;
        _isSubmitting = false;
      });
      _focusNode.unfocus();
    }
  }

  bool get _showSubmitButton =>
      _feedback == _ReferralFeedback.none && !_isSubmitting;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasText = _controller.text.trim().isNotEmpty;
    final canSubmit = hasText && !_isSubmitting && _showSubmitButton;

    final inputBorderColor =
        isDark ? MyColors.referralInputBorderDark : MyColors.inputBorder;

    final disabledButtonBg = isDark
        ? MyColors.referralButtonDisabledDark
        : MyColors.referralButtonDisabledLight;
    final disabledButtonText = isDark
        ? MyColors.referralButtonDisabledTextDark
        : MyColors.referralButtonDisabledTextLight;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: Dimens.nw(360.0)),
        padding: EdgeInsets.all(Dimens.medium),
        decoration: BoxDecoration(
          color: isDark ? MyColors.termsBackgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(Dimens.nr(10.0)),
              onTap: _toggleExpanded,
              child: SizedBox(
                height: Dimens.nh(40),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'کد معرف',
                      style: MyTextStyle.referralCodeTitle14MediumFor(isDark),
                    ),
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
              Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: Dimens.nh(45)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.nr(10)),
                  border: Border.all(color: inputBorderColor, width: 1),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textDirection:
                            hasText ? TextDirection.ltr : TextDirection.rtl,
                        textAlign: TextAlign.right,
                        textAlignVertical: TextAlignVertical.top,
                        enabled: !_isSubmitting &&
                            _feedback != _ReferralFeedback.success,
                        style: MyTextStyle.referralCodeValue14MediumFor(isDark),
                        onTap: _ensureVisible,
                        onChanged: _onTextChanged,
                        onSubmitted: (_) {
                          if (canSubmit) _handleSubmit();
                        },
                        decoration: InputDecoration(
                          hintText: 'کد تخفیف را وارد کنید',
                          hintTextDirection: TextDirection.rtl,
                          hintStyle:
                              MyTextStyle.referralCodeHint14RegularFor(isDark),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Dimens.nw(12),
                            vertical: Dimens.nh(12),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_showSubmitButton)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: Dimens.nw(8),
                          end: Dimens.nw(3.5),
                          top: Dimens.nh(3.5),
                          bottom: Dimens.nh(3.5),
                        ),
                        child: SizedBox(
                          width: Dimens.nw(85),
                          height: Dimens.nh(38),
                          child: ElevatedButton(
                            onPressed: canSubmit ? _handleSubmit : () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canSubmit
                                  ? MyColors.primary
                                  : disabledButtonBg,
                              disabledBackgroundColor: disabledButtonBg,
                              foregroundColor:
                                  canSubmit ? Colors.white : disabledButtonText,
                              disabledForegroundColor: disabledButtonText,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimens.nr(7)),
                              ),
                            ),
                            child: Text(
                              'ثبت کد',
                              style: MyTextStyle.referralCodeButton12BoldFor(
                                canSubmit ? Colors.white : disabledButtonText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_isSubmitting)
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: Dimens.nw(8),
                          end: Dimens.nw(12),
                        ),
                        child: SizedBox(
                          width: Dimens.nr(20),
                          height: Dimens.nr(20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MyColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_feedback == _ReferralFeedback.success) ...[
                SizedBox(height: Dimens.nh(8)),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    'کد معرف صحیح است.',
                    style: MyTextStyle.referralCodeFeedbackSuccess12MediumFor(
                      isDark,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
              if (_feedback == _ReferralFeedback.error) ...[
                SizedBox(height: Dimens.nh(8)),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    'کد معرف صحیح نمی باشد.',
                    style: MyTextStyle.referralCodeFeedbackError12MediumFor(
                      isDark,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
