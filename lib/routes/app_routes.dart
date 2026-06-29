// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const SPLASH = _Paths.SPLASH;
  static const GETSTARTED = _Paths.GETSTARTED;
  static const PROFILE = _Paths.PROFILE;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const SUPPORT = _Paths.SUPPORT;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const ADMIN_LOGIN = _Paths.ADMIN_LOGIN;
  static const BOTTOM_NAV = _Paths.BOTTOM_NAV;
}

abstract class _Paths {
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const SPLASH = '/splash';
  static const GETSTARTED = '/getStarted';
  static const PROFILE = '/profile';
  static const ONBOARDING = '/onboarding';
  static const SUPPORT = '/support';
  static const ADMIN_DASHBOARD = '/admin-dashboard';
  static const ADMIN_LOGIN = '/admin-login';
  static const BOTTOM_NAV = '/main';
}
