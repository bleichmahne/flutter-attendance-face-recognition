import 'package:flutter/material.dart';

class AppLocaleScope extends InheritedWidget {
  final Locale? locale;
  final void Function(Locale?) setLocale;

  const AppLocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  static AppLocaleScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return locale != oldWidget.locale;
  }
}
