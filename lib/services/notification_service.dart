import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal({FlutterLocalNotificationsPlugin? plugin})
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initializes local notifications with platform specific settings
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
      );

      await requestPermissions();
    } catch (_) {
      // In tests or non-supported headless environments, fail gracefully
    } finally {
      _isInitialized = true;
    }
  }

  /// Request runtime notification permissions on Android 13+ (API 33+) and iOS
  Future<bool?> requestPermissions() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        return await androidImplementation.requestNotificationsPermission();
      }
    } catch (_) {}
    return false;
  }

  /// Displays a local push notification for low or out-of-stock items
  Future<void> showLowStockAlert({
    required String productName,
    required int remainingStock,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'low_stock_channel',
        'Low Stock Alerts',
        channelDescription:
            'Notifications for products reaching low or zero stock',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _notificationsPlugin.show(
        notificationId,
        '⚠️ Low Stock Alert: $productName',
        'Only $remainingStock units remaining in inventory. Please reorder soon.',
        notificationDetails,
      );
    } catch (_) {
      // Graceful fallback for test environments or headless runners
    }
  }

  /// Universal audit notification for products, movements, invoices, and damages
  Future<void> showAuditNotification({
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'audit_channel',
        'Audit & Operations',
        channelDescription:
            'System notifications for product, stock, damage, and invoice events',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      final int notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _notificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (_) {
      // Graceful fallback for test environments or headless runners
    }
  }
}
