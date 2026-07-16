import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Сервис локальных уведомлений
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    _initialized = true;
  }

  /// Уведомление о пользователе рядом
  Future<void> notifyNearbyUser({
    required String name,
    required String beaconText,
  }) async {
    await _plugin.show(
      1,
      '📍 $name рядом с тобой!',
      '$beaconText — начни чат, пока он(а) здесь',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nearby_users',
          'Пользователи рядом',
          channelDescription: 'Уведомления о пользователях рядом',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Уведомление о сгорании чата
  Future<void> notifyChatBurning({
    required String partnerName,
    required int secondsLeft,
  }) async {
    final mins = secondsLeft ~/ 60;
    await _plugin.show(
      2,
      '🔥 Чат горит!',
      'До конца разговора с $partnerName — $mins минут. Успей!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_burning',
          'Горящий чат',
          channelDescription: 'Уведомления о сгорании чата',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Уведомление о новом сообщении
  Future<void> notifyNewMessage({
    required String senderName,
    required String message,
    required String chatId,
  }) async {
    await _plugin.show(
      3,
      '💬 $senderName',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'new_messages',
          'Новые сообщения',
          channelDescription: 'Уведомления о новых сообщениях',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}
