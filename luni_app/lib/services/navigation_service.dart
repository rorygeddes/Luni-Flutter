import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToModal(Widget modal) {
    final context = navigatorKey.currentContext!;
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => modal,
    );
  }

  static void goBack() {
    navigatorKey.currentState!.pop();
  }

  static void goToHome() {
    navigatorKey.currentState!.pushNamedAndRemoveUntil('/', (route) => false);
  }
}

