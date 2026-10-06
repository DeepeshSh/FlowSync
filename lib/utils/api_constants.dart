class ApiConstants {
  // Production Cloud / Render backend
  static const String baseUrl = "https://flowsync-backend-iknk.onrender.com/api";
  static const String auth = '$baseUrl/auth';
  static const String products = '$baseUrl/products';
  static const String profile = '$baseUrl/profile';
  static const String personalProfile = '$profile/personal';
  static const String businessProfile = '$profile/business';
  static const String movements = '$baseUrl/movements';
  static const String allMovements = '$movements/all';
  static const String damagedMovements = '$movements/damaged';
  static const String parties = '$baseUrl/parties';
  static const String invoices = '$baseUrl/invoices';

  // Auth sub-endpoints
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String me = '$auth/me';
}
