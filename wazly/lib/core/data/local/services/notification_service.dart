import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String _kChannelId = 'wazly_reminders_v3';
const String _kChannelName = 'Wazly Reminders';
const String _kChannelDesc = 'Debt and payment reminder notifications';
const String _kSoundFile = 'wazly_notification';

void _log(String msg) {
  debugPrint('[NotifService] $msg');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String _resolvedTzName = 'unknown';

  final Map<int, Timer> _activeTimers = {};

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    try {
      _resolvedTzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(_resolvedTzName));
      _log('⏰ Timezone set: $_resolvedTzName');
    } catch (e) {
      _resolvedTzName = 'UTC (fallback)';
      tz.setLocalLocation(tz.UTC);
      _log('⚠️ Timezone detection failed: $e → using UTC');
    }

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
          android: android, iOS: darwin, macOS: darwin),
      onDidReceiveNotificationResponse: (response) {
        _log('🔔 Notification tapped: ${response.id}');
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _kChannelId,
          _kChannelName,
          description: _kChannelDesc,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(_kSoundFile),
          enableVibration: true,
        ),
      );
      _log('✅ Android channel created: $_kChannelId');
    }

    _isInitialized = true;
    _log('✅ Initialized OK');
  }

  // ─────────────────────────────────────────────
  // Permissions
  // ─────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _log('🔑 iOS permission granted: $granted');
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final notifGranted =
          await androidPlugin?.requestNotificationsPermission();
      _log('🔑 POST_NOTIFICATIONS granted: $notifGranted');

      final exactGranted =
          await androidPlugin?.requestExactAlarmsPermission();
      _log('🔑 SCHEDULE_EXACT_ALARM granted: $exactGranted');

      final canExact =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      _log('🔑 canScheduleExactNotifications: $canExact');

      return notifGranted ?? false;
    }
    return true;
  }

  // ─────────────────────────────────────────────
  // Notification details
  // ─────────────────────────────────────────────

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        channelDescription: _kChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(_kSoundFile),
        enableVibration: true,
        showWhen: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(sound: '$_kSoundFile.mp3'),
      macOS: DarwinNotificationDetails(sound: '$_kSoundFile.mp3'),
    );
  }

  // ─────────────────────────────────────────────
  // Cancel helpers
  // ─────────────────────────────────────────────

  Future<void> cancelReminder(int id) async {
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);
    await _plugin.cancel(id: id);
    _log('🗑️ Cancelled notification ID: $id');
  }

  Future<void> cancelAllReminders() async {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    await _plugin.cancelAll();
    _log('🗑️ Cancelled ALL notifications');
  }

  // ─────────────────────────────────────────────
  // Core: fire a notification immediately via show()
  // ─────────────────────────────────────────────

  Future<void> _fireNow({
    required int id,
    required String title,
    required String body,
  }) async {
    _log('🔔 Firing notification #$id NOW');
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  // ─────────────────────────────────────────────
  // Schedule via zonedSchedule + in-app Timer fallback
  // ─────────────────────────────────────────────

  Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final now = DateTime.now();
    final fireAt = scheduledDate.toLocal();
    final delay = fireAt.difference(now);

    _log('📅 Scheduling #$id for $scheduledDate (delay: ${delay.inSeconds}s)');

    // 1) Try zonedSchedule (AlarmManager)
    try {
      AndroidScheduleMode scheduleMode;
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final canExact =
            await androidPlugin?.canScheduleExactNotifications() ?? false;
        scheduleMode = canExact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle;
        _log('📅 Using schedule mode: $scheduleMode (canExact=$canExact)');
      } else {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _details(),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      _log('✅ zonedSchedule succeeded for #$id');
    } catch (e) {
      _log('❌ zonedSchedule failed for #$id: $e');
    }

    // 2) In-app Timer fallback (works while app is alive, bypasses MIUI restrictions)
    if (delay.isNegative) return;

    _activeTimers[id]?.cancel();

    if (matchDateTimeComponents != null) {
      // Repeating: fire once at scheduledDate, then reschedule for next occurrence
      _activeTimers[id] = Timer(delay, () {
        _log('⏰ Timer (recurring) fired for #$id');
        _fireNow(id: id, title: title, body: body);
        _activeTimers.remove(id);

        // Reschedule for next occurrence
        final nextDate = _nextOccurrence(scheduledDate, matchDateTimeComponents);
        if (nextDate != null) {
          _scheduleWithFallback(
            id: id,
            title: title,
            body: body,
            scheduledDate: nextDate,
            matchDateTimeComponents: matchDateTimeComponents,
          );
        }
      });
      _log('⏰ Timer (recurring) set for #$id in ${delay.inSeconds}s');
    } else {
      // One-shot
      _activeTimers[id] = Timer(delay, () {
        _log('⏰ Timer fallback fired for #$id');
        _fireNow(id: id, title: title, body: body);
        _activeTimers.remove(id);
      });
      _log('⏰ Timer fallback set for #$id in ${delay.inSeconds}s');
    }
  }

  tz.TZDateTime? _nextOccurrence(
      tz.TZDateTime current, DateTimeComponents? components) {
    if (components == DateTimeComponents.dayOfWeekAndTime) {
      return current.add(const Duration(days: 7));
    } else if (components == DateTimeComponents.time) {
      return current.add(const Duration(days: 1));
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // Immediate / test notification
  // ─────────────────────────────────────────────

  Future<void> sendTestNotification() async {
    await requestPermissions();
    _log('📤 Sending immediate test notification');
    await _fireNow(
      id: 9999,
      title: 'Wazly — إشعار تجريبي 🔔',
      body: 'الإشعارات تعمل بشكل صحيح! يمكنك الآن ضبط التذكيرات.',
    );
  }

  // ─────────────────────────────────────────────
  // ★ DEBUG: Schedule a notification 1 minute from now
  // ─────────────────────────────────────────────

  Future<String> scheduleTestIn1Minute() async {
    await requestPermissions();

    final now = tz.TZDateTime.now(tz.local);
    final target = now.add(const Duration(minutes: 1));

    final log = StringBuffer();
    log.writeln('═══ Notification Schedule Debug ═══');
    log.writeln('Timezone  : $_resolvedTzName');
    log.writeln('Now (TZ)  : $now');
    log.writeln('Target    : $target');
    log.writeln('Delta ms  : ${target.difference(now).inMilliseconds}ms');
    log.writeln('Is future : ${target.isAfter(now)}');
    log.writeln('Initialized: $_isInitialized');

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final canExact =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      log.writeln('CanExact  : $canExact');
      log.writeln('Mode      : ${canExact ? "exact" : "inexact"} + Timer fallback');
    }

    _log(log.toString());

    try {
      await _scheduleWithFallback(
        id: 8888,
        title: 'Wazly — تذكير اختباري ⏰',
        body: 'تم جدولة هذا الإشعار قبل دقيقة واحدة. TZ: $_resolvedTzName',
        scheduledDate: target,
      );
      log.writeln('Status    : ✅ Scheduled + Timer fallback set');
    } catch (e) {
      log.writeln('Status    : ❌ Error: $e');
      _log('❌ Schedule error: $e');
    }

    return log.toString();
  }

  // ─────────────────────────────────────────────
  // One-time reminder
  // ─────────────────────────────────────────────

  Future<bool> scheduleOneTimeReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!scheduledDate.isAfter(DateTime.now())) {
      _log('⚠️ scheduleOneTimeReminder: date is NOT in the future: $scheduledDate');
      return false;
    }

    final granted = await requestPermissions();
    if (!granted) {
      _log('⚠️ scheduleOneTimeReminder: POST_NOTIFICATIONS not granted');
      return false;
    }

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    await _scheduleWithFallback(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzDate,
    );
    return true;
  }

  // ─────────────────────────────────────────────
  // Daily reminder at a specific time & weekday set
  // ─────────────────────────────────────────────

  Future<void> scheduleDailyReminders({
    required int baseId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required Set<int> weekdays,
  }) async {
    for (int i = 0; i < 7; i++) {
      await cancelReminder(baseId + i);
    }
    if (weekdays.isEmpty) return;

    for (final day in weekdays) {
      final slotId = baseId + (day - 1);
      final scheduled = _nextWeekdayTime(day, hour, minute);
      await _scheduleWithFallback(
        id: slotId,
        title: title,
        body: body,
        scheduledDate: scheduled,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
    _log('✅ Scheduled ${weekdays.length} daily slots at $hour:$minute');
  }

  // ─────────────────────────────────────────────
  // Weekly reminder (single day + time)
  // ─────────────────────────────────────────────

  Future<void> scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    await cancelReminder(id);
    final scheduled = _nextWeekdayTime(weekday, hour, minute);
    await _scheduleWithFallback(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  tz.TZDateTime _nextWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}

// ─────────────────────────────────────────────
// Convenience helpers (kept for backwards compat)
// ─────────────────────────────────────────────

class Time {
  final int hour;
  final int minute;
  final int second;
  const Time(this.hour, this.minute, this.second);
}

enum Day {
  monday(DateTime.monday),
  tuesday(DateTime.tuesday),
  wednesday(DateTime.wednesday),
  thursday(DateTime.thursday),
  friday(DateTime.friday),
  saturday(DateTime.saturday),
  sunday(DateTime.sunday);

  final int value;
  const Day(this.value);
}
