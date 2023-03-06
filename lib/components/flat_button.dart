import 'package:flutter/material.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';

class FlatButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsets? padding;
  final Color backgroundColor;
  final Color forgroundColor;
  final Color borderColor;

  const FlatButton(
      {required this.onPressed,
      required this.child,
      required this.backgroundColor,
      required this.forgroundColor,
      required this.borderColor,
      this.padding,
      Key? key})
      : super(key: key);

  factory FlatButton.primary({
    required VoidCallback onPressed,
    required Widget child,
    EdgeInsets? padding,
    Key? key,
  }) {
    final AppTheme apptheme = locator<AppTheme>();
    return FlatButton(
      onPressed: onPressed,
      child: child,
      padding: padding,
      key: key,
      backgroundColor: apptheme.primary,
      forgroundColor: Colors.white,
      borderColor: apptheme.primary,
    );
  }

  factory FlatButton.outline({
    required VoidCallback onPressed,
    required Widget child,
    EdgeInsets? padding,
    Key? key,
  }) {
    final AppTheme apptheme = locator<AppTheme>();
    return FlatButton(
      onPressed: onPressed,
      child: child,
      padding: padding,
      key: key,
      backgroundColor: Colors.white,
      forgroundColor: apptheme.primary,
      borderColor: apptheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    var _padding = padding ?? const EdgeInsets.fromLTRB(40, 10, 40, 10);

    return TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            _padding,
          ),
          foregroundColor: MaterialStateProperty.all<Color>(forgroundColor),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
              side: BorderSide(color: borderColor),
            ),
          ),
        ),
        onPressed: onPressed,
        child: child);
  }
}
