/// Application-level constants
class AppConstants {
  /// Application name
  static const String appName = 'sim_tchad';
  
  /// API endpoints
  static const String baseUrl = 'https://api.sim-prix.net/api/';
  // static const String baseUrl = 'http://10.0.2.2:5600/api/';
  
  static const int MAX_RETRIES = 3;
 static const int RETRY_DELAY = 3000;

  /// Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  
  /// Route names
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String splashRoute = '/splash';
}
