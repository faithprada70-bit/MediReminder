import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool _canScheduleExact = false;

  Future<void> initialize() async {
    try {
      tzdata.initializeTimeZones();

      try {
        final timeZone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZone.identifier));
      } catch (e) {
        debugPrint('Timezone detection failed: $e');
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );

      await _plugin.initialize(settings);

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      _canScheduleExact =
          await android?.canScheduleExactNotifications() ?? false;

      _ready = true;
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
      _ready = false;
    }
  }

  Future<bool> requestPermission() async {
    if (!_ready) return false;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final notificationPermission =
          await android.requestNotificationsPermission();

      _canScheduleExact = await android.requestExactAlarmsPermission() ?? false;

      return notificationPermission ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return result ?? false;
    }

    return false;
  }

  NotificationDetails get _notificationDetails {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine reminders',
        channelDescription: 'Reminders for your saved medicine schedule',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  AndroidScheduleMode get _scheduleMode {
    return _canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  // One-time reminder, also used for Snooze.
  Future<bool> scheduleMedicineReminder({
    required int id,
    required String medicineName,
    required DateTime dateTime,
  }) async {
    if (!_ready) return false;

    try {
      final scheduledTime = tz.TZDateTime.from(dateTime, tz.local);

      if (!scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
        return false;
      }

      await _plugin.zonedSchedule(
        id.abs(),
        'Medicine Reminder',
        'It is time for $medicineName.',
        scheduledTime,
        _notificationDetails,
        androidScheduleMode: _scheduleMode,
      );

      return true;
    } catch (e) {
      debugPrint('Failed to schedule medicine reminder: $e');
      return false;
    }
  }

  // Repeating daily reminder.
  Future<bool> scheduleDailyMedicineReminder({
    required int id,
    required String medicineName,
    required DateTime dateTime,
  }) async {
    if (!_ready) return false;

    try {
      var scheduledTime = tz.TZDateTime.from(
        dateTime,
        tz.local,
      );

      final now = tz.TZDateTime.now(tz.local);

      if (!scheduledTime.isAfter(now)) {
        scheduledTime = scheduledTime.add(
          const Duration(days: 1),
        );
      }

      await _plugin.zonedSchedule(
        id.abs(),
        'Medicine Reminder',
        'It is time for $medicineName.',
        scheduledTime,
        _notificationDetails,
        androidScheduleMode: _scheduleMode,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return true;
    } catch (e) {
      debugPrint('Failed to schedule daily medicine reminder: $e');
      return false;
    }
  }

  Future<void> cancelReminder(int id) async {
    if (!_ready) return;

    await _plugin.cancel(id.abs());
  }

  Future<void> cancelAll() async {
    if (!_ready) return;

    await _plugin.cancelAll();
  }
}
