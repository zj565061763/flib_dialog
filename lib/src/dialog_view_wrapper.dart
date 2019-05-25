import 'package:flutter/material.dart';

import 'dialog.dart';

const Color _kDefaultBackgroundColor = Colors.white;
const double _kDefaultElevation = 0;
const double _kDefaultPaddingWidthPercent = 0.1;

class FOriginalDialogViewWrapper implements FDialogViewWrapper {
  @override
  Widget wrap(BuildContext context, Widget widget) {
    return widget;
  }
}

class FSimpleDialogViewWrapper implements FDialogViewWrapper {
  final Color backgroundColor;
  final double elevation;
  final BorderRadiusGeometry borderRadius;

  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  FSimpleDialogViewWrapper({
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.alignment,
  });

  @override
  Widget wrap(BuildContext context, Widget child) {
    assert(child != null);
    assert(context != null);

    final DialogTheme dialogTheme = DialogTheme.of(context);
    final MediaQueryData mediaQueryData = MediaQuery.of(context);

    final Color targetBackgroundColor = backgroundColor ??
        dialogTheme.backgroundColor ??
        Theme.of(context).dialogBackgroundColor ??
        _kDefaultBackgroundColor;

    final double targetElevation =
        elevation ?? dialogTheme.elevation ?? _kDefaultElevation;

    final BorderRadiusGeometry targetBorderRadius =
        borderRadius ?? BorderRadius.circular(5.0);

    final EdgeInsets targetPadding = padding ??
        EdgeInsets.all(
            mediaQueryData.size.width * _kDefaultPaddingWidthPercent);

    final AlignmentGeometry targetAlignment = alignment ?? Alignment.center;

    Widget current = Material(
      color: targetBackgroundColor,
      elevation: targetElevation,
      shape: RoundedRectangleBorder(
        borderRadius: targetBorderRadius,
      ),
      type: MaterialType.card,
      child: child,
    );

    current = Container(
      alignment: targetAlignment,
      padding: targetPadding,
      child: current,
    );

    if (targetPadding.left == 0 &&
        targetPadding.top == 0 &&
        targetPadding.right == 0 &&
        targetPadding.bottom == 0) {
      current = SafeArea(child: current);
    }

    return current;
  }
}
