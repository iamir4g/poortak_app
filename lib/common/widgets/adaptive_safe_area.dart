import 'package:flutter/material.dart';

/// Marks widgets embedded inside [MainWrapper]'s tab [PageView].
class MainWrapperScope extends InheritedWidget {
  const MainWrapperScope({
    super.key,
    required this.isEmbedded,
    required super.child,
  });

  final bool isEmbedded;

  static bool isEmbeddedInMainWrapper(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<MainWrapperScope>()
            ?.isEmbedded ??
        false;
  }

  @override
  bool updateShouldNotify(MainWrapperScope oldWidget) {
    return oldWidget.isEmbedded != isEmbedded;
  }
}

/// Applies [SafeArea] only when the screen is pushed as a standalone route.
/// Tab screens inside [MainWrapper] already get top/bottom insets from its
/// [Scaffold] app bar and bottom navigation bar.
class AdaptiveSafeArea extends StatelessWidget {
  const AdaptiveSafeArea({
    super.key,
    required this.child,
    this.left = true,
    this.right = true,
  });

  final Widget child;
  final bool left;
  final bool right;

  @override
  Widget build(BuildContext context) {
    final embedded = MainWrapperScope.isEmbeddedInMainWrapper(context);
    if (embedded) {
      return child;
    }

    return SafeArea(
      left: left,
      right: right,
      child: child,
    );
  }
}
