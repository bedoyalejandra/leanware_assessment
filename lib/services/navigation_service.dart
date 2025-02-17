import 'package:flutter/material.dart';
import '../../main.dart';

class NavigationService {
  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }
  late GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  Future<dynamic> navigateToReplacement(String _rn, {Object? arguments}) =>
      navigationKey.currentState!
          .pushReplacementNamed(_rn, arguments: arguments);

  Future<dynamic> navigateTo(String _rn, {Object? arguments}) {
    return navigationKey.currentState!.pushNamed(_rn, arguments: arguments);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _rn) =>
      navigationKey.currentState!.push(_rn);

  BuildContext? getContext() => navigationKey.currentContext;

  void goBack() {
    if (navigationKey.currentState!.canPop()) {
      navigationKey.currentState!.pop();
    } else {
      navigationKey.currentState!.pushReplacementNamed('home');
    }
  }

  Future<dynamic> navigateWithTransition(
    String routeName, {
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 200),
    RouteTransitionsBuilder transitionsBuilder = _defaultTransition,
  }) =>
      navigationKey.currentState!.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _getRouteWidget(context, routeName, arguments),
          transitionDuration: transitionDuration,
          transitionsBuilder: transitionsBuilder,
        ),
      );

  Future<dynamic> navigateToReplacementWithTransition(
    String routeName, {
    Object? arguments,
    Duration transitionDuration = const Duration(milliseconds: 300),
    RouteTransitionsBuilder transitionsBuilder = _defaultTransition,
  }) =>
      navigationKey.currentState!.push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              _getRouteWidget(context, routeName, arguments),
          transitionDuration: transitionDuration,
          transitionsBuilder: transitionsBuilder,
        ),
      );

  static Widget _defaultTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(opacity: animation, child: child);

  Widget _getRouteWidget(
    BuildContext context,
    String routeName,
    Object? arguments,
  ) {
    var routeSettings = RouteSettings(name: routeName, arguments: arguments);
    var route = Navigator.of(context).widget.onGenerateRoute!(routeSettings);
    if (route == null) {
      throw Exception('Route "$routeName" not found');
    }
    return (route as MaterialPageRoute).builder(context);
  }
}
