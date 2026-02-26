import 'package:flutter/material.dart';
import 'package:poortak/config/dimens.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';

class LitnerCard extends StatelessWidget {
  final LinearGradient gradient;
  final String icon;
  final String number;
  final String label;
  final String subLabel;
  final VoidCallback onTap;
  const LitnerCard({
    required this.gradient,
    required this.icon,
    required this.number,
    required this.label,
    required this.subLabel,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: Dimens.nh(143.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(Dimens.nr(40.0)),
        ),
        child: Row(
          children: [
            // Right: White circle with image
            Padding(
              padding:
                  EdgeInsets.only(right: Dimens.medium, left: Dimens.small),
              child: Container(
                width: Dimens.nr(79.0),
                height: Dimens.nr(79.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: Dimens.nr(44.0),
                    height: Dimens.nr(44.0),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Center/Left: Texts
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: Dimens.medium,
                  left: Dimens.large,
                  top: Dimens.nw(20.0),
                  bottom: Dimens.nw(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            number,
                            style: MyTextStyle.textMatn18Bold.copyWith(
                              fontSize: Dimens.nsp(20.0),
                              color: MyColors.darkText1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: Dimens.small),
                        Flexible(
                          child: Text(
                            label,
                            style: MyTextStyle.textMatn17W700.copyWith(
                              fontSize: Dimens.nsp(20.0),
                              color: MyColors.darkText1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimens.small),
                    Text(
                      subLabel,
                      style: MyTextStyle.textMatn12W500.copyWith(
                        color: MyColors.text3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LitnerTodayCard extends StatelessWidget {
  final String number;
  final String label;
  final String buttonText;
  final String imageAsset;
  final VoidCallback onTap;
  const LitnerTodayCard({
    this.number = '۳',
    this.label = 'کارت های امروز',
    this.buttonText = 'شروع',
    this.imageAsset = 'assets/images/litner/flash-card.png',
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: Dimens.nh(112.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF5DB), Color(0xFFFEE8DB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(Dimens.nr(40.0)),
        ),
        child: Row(
          children: [
            // Right: White circle with image
            Padding(
              padding:
                  EdgeInsets.only(right: Dimens.medium, left: Dimens.small),
              child: Container(
                width: Dimens.nr(79.0),
                height: Dimens.nr(79.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    imageAsset,
                    width: Dimens.nr(42.0),
                    height: Dimens.nr(41.0),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Center: Texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: MyTextStyle.textMatn18Bold.copyWith(
                      fontSize: Dimens.nsp(20.0),
                      color: MyColors.darkText1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Dimens.nh(2.0)),
                  Text(
                    label,
                    style: MyTextStyle.textMatn12W500.copyWith(
                      color: MyColors.text3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Left: Button
            Padding(
              padding:
                  EdgeInsets.only(left: Dimens.nw(18.0), right: Dimens.small),
              child: Container(
                width: Dimens.nw(105.0),
                height: Dimens.nh(44.0),
                decoration: BoxDecoration(
                  color: MyColors.primary,
                  borderRadius: BorderRadius.circular(Dimens.nr(30.0)),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.small),
                  child: Text(
                    buttonText,
                    style: MyTextStyle.textMatnBtn.copyWith(
                      fontSize: Dimens.nsp(14.0),
                      color: MyColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
