import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

/// Result of a schedule attempt, including whether exact or inexact was used.
class ScheduleResult {
  final bool success;
  final bool usedExactAlarm;
  final bool exactPermissionMissing;
  final String? error;

  const ScheduleResult({
    required this.success,
    required this.usedExactAlarm,
    this.exactPermissionMissing = false,
    this.error,
  });
}

/// Wazly Notification Service
///
/// Scheduling Strategy:
///   EXACT path  → used when SCHEDULE_EXACT_ALARM permission is granted by the
///                 user through Android Settings → "Alarms & reminders".
///                 Fires at the precise time, even if the app is killed.
///
///   INEXACT path → fallback when exact permission is absent.
///                 May be delayed by Android Doze. Acceptable as a degraded mode.
///                 Callers are informed via [ScheduleResult.exactPermissionMissing].
///
/// What is NOT used:
///   - Dart Timer  → in-memory, dies when the process is killed.
///   - USE_EXACT_ALARM → reserved for alarm-clock / calendar apps.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String _resolvedTzName = 'unknown';

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Timezone
    tz.initializeTimeZones();
    try {
      _resolvedTzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(_resolvedTzName));
      _log('⏰ Timezone: $_resolvedTzName');
    } catch (e) {
      _resolvedTzName = 'UTC (fallback)';
      tz.setLocalLocation(tz.UTC);
      _log('⚠️ Timezone fallback to UTC: $e');
    }

    // 2. Plugin init
    const android = AndroidInitializationSettings('ic_stat_wazly');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
      onDidReceiveNotificationResponse: (response) {
        _log('🔔 Tapped: id=${response.id}');
      },
    );

    // 3. Android channel
    if (Platform.isAndroid) {
      final ap = _androidPlugin();
      await ap?.createNotificationChannel(
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
      _log('✅ Channel ready: $_kChannelId');
    }

    _isInitialized = true;
    _log('✅ NotificationService initialized');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Exact alarm permission helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true if the app currently holds the SCHEDULE_EXACT_ALARM permission.
  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final canExact =
        await _androidPlugin()?.canScheduleExactNotifications() ?? false;
    _log('🔑 canScheduleExactAlarms: $canExact');
    return canExact;
  }

  /// Opens the Android "Alarms & reminders" settings page so the user can
  /// manually grant the SCHEDULE_EXACT_ALARM permission.
  ///
  /// This does NOT guarantee the user will grant it — the caller is responsible
  /// for checking [canScheduleExactAlarms()] again after the user returns.
  ///
  /// Call this when [ScheduleResult.exactPermissionMissing] == true and you
  /// want to prompt the user with a dialog first.
  Future<void> ensureExactAlarmPermissionIfNeeded() async {
    if (!Platform.isAndroid) return;
    final canExact = await canScheduleExactAlarms();
    if (canExact) {
      _log('✅ ensureExactAlarmPermissionIfNeeded: already granted');
      return;
    }
    _log('📲 Opening Android Alarms & Reminders settings...');
    try {
      // requestExactAlarmsPermission opens the system settings page for
      // SCHEDULE_EXACT_ALARM. The user must manually toggle the app on.
      await _androidPlugin()?.requestExactAlarmsPermission();
    } on PlatformException catch (e) {
      _log('⚠️ requestExactAlarmsPermission PlatformException: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Permissions (POST_NOTIFICATIONS)
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _log('🔑 iOS/macOS permission: $granted');
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final granted =
          await _androidPlugin()?.requestNotificationsPermission() ?? false;
      _log('🔑 POST_NOTIFICATIONS: $granted');
      return granted;
    }

    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notification details
  // ─────────────────────────────────────────────────────────────────────────

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
        category: AndroidNotificationCategory.reminder,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        presentBadge: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cancel helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id: id);
    _log('🗑️ Cancelled id=$id');
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
    _log('🗑️ Cancelled ALL notifications');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Core: Immediate show
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _fireNow({
    required int id,
    required String title,
    required String body,
  }) async {
    _log('🔔 show() id=$id');
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Core: zonedSchedule — exact when permitted, inexact as fallback
  //
  // EXACT  (exactAllowWhileIdle):
  //   Fires at the precise moment via AlarmManager's setExactAndAllowWhileIdle.
  //   Works even when app is killed + device in Doze.
  //   Requires SCHEDULE_EXACT_ALARM permission granted in Android Settings.
  //
  // INEXACT (inexactAllowWhileIdle):
  //   Uses AlarmManager's setAndAllowWhileIdle.
  //   May be delayed up to ~15 min in deep Doze — or missed on aggressive ROMs.
  //   No special permission required.
  //   Used automatically when exact permission is absent.
  // ─────────────────────────────────────────────────────────────────────────

  Future<ScheduleResult> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    // Determine schedule mode
    bool canExact = false;
    AndroidScheduleMode mode = AndroidScheduleMode.inexactAllowWhileIdle;

    if (Platform.isAndroid) {
      canExact =
          await _androidPlugin()?.canScheduleExactNotifications() ?? false;

      if (canExact) {
        mode = AndroidScheduleMode.exactAllowWhileIdle;
      } else {
        mode = AndroidScheduleMode.inexactAllowWhileIdle;
      }
    }

    _log(
      '📅 [schedule] id=$id'
      ' | target=$scheduledDate'
      ' | tz=$_resolvedTzName'
      ' | exactGranted=$canExact'
      ' | mode=$mode'
      '${matchDateTimeComponents != null ? " | repeat=$matchDateTimeComponents" : ""}',
    );

    if (!canExact) {
      _log(
        '⚠️ [schedule] SCHEDULE_EXACT_ALARM not granted. '
        'Using inexact fallback — notification may be delayed or not arrive '
        'on aggressive ROMs (MIUI, OneUI). '
        'Call ensureExactAlarmPermissionIfNeeded() to ask user to enable it.',
      );
    }

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _details(),
        androidScheduleMode: mode,
        matchDateTimeComponents: matchDateTimeComponents,
      );

      _log('✅ [schedule] zonedSchedule OK for id=$id');

      // Verify registration in AlarmManager
      final pending = await _plugin.pendingNotificationRequests();
      final found = pending.any((n) => n.id == id);
      _log(
        found
            ? '✅ [schedule] confirmed in pending list id=$id'
            : '❌ [schedule] WARNING — id=$id NOT in pending list! '
                  'All IDs: ${pending.map((n) => n.id).toList()}',
      );

      return ScheduleResult(
        success: true,
        usedExactAlarm: canExact,
        exactPermissionMissing: !canExact,
      );
    } catch (e, st) {
      _log('❌ [schedule] FAILED id=$id: $e\n$st');
      return ScheduleResult(
        success: false,
        usedExactAlarm: false,
        exactPermissionMissing: !canExact,
        error: e.toString(),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Immediate test notification (fires right now).
  Future<void> sendTestNotification() async {
    await requestPermissions();
    _log('📤 Sending test notification now');
    await _fireNow(
      id: 9999,
      title: 'Wazly — إشعار تجريبي 🔔',
      body: 'الإشعارات تعمل بشكل صحيح! يمكنك الآن ضبط التذكيرات.',
    );
  }

  /// DEBUG: Schedule a notification 1 minute from now.
  /// Returns a log string you can display in the UI.
  Future<String> scheduleTestIn1Minute() async {
    await requestPermissions();

    final now = tz.TZDateTime.now(tz.local);
    final target = now.add(const Duration(minutes: 1));

    final log = StringBuffer();
    log.writeln('═══ Notification Debug ═══');
    log.writeln('tz         : $_resolvedTzName');
    log.writeln('now        : $now');
    log.writeln('target     : $target');
    log.writeln('delta      : ${target.difference(now).inSeconds}s');
    log.writeln('initialized: $_isInitialized');

    if (Platform.isAndroid) {
      final canExact = await canScheduleExactAlarms();
      log.writeln('exactGranted: $canExact');
      log.writeln(
        'mode       : ${canExact ? "exactAllowWhileIdle ✅" : "inexactAllowWhileIdle ⚠️"}',
      );
      if (!canExact) {
        log.writeln(
          'ACTION     : Go to Settings → Apps → Wazly → Alarms & reminders → Allow',
        );
      }
    }

    final result = await _schedule(
      id: 8888,
      title: 'Wazly — تذكير اختباري ⏰',
      body: 'تم جدولته قبل دقيقة. TZ: $_resolvedTzName',
      scheduledDate: target,
    );

    log.writeln('success    : ${result.success}');
    log.writeln('usedExact  : ${result.usedExactAlarm}');
    if (!result.usedExactAlarm) {
      log.writeln(
        '⚠️ Exact alarm not used — reminders may be delayed or missed',
      );
    }
    if (result.error != null) log.writeln('error      : ${result.error}');

    final pending = await _plugin.pendingNotificationRequests();
    final found = pending.any((n) => n.id == 8888);
    log.writeln(
      'pending    : ${found ? "✅ registered in AlarmManager" : "❌ NOT registered!"}',
    );

    _log(log.toString());
    return log.toString();
  }

  /// One-time reminder. Returns a [ScheduleResult] so the caller can decide
  /// whether to show the user a "please enable exact alarms" prompt.
  Future<ScheduleResult> scheduleOneTimeReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!scheduledDate.isAfter(DateTime.now())) {
      _log('⚠️ scheduleOneTimeReminder: not in future: $scheduledDate');
      return const ScheduleResult(
        success: false,
        usedExactAlarm: false,
        error: 'Date not in future',
      );
    }

    final granted = await requestPermissions();
    if (!granted) {
      _log('⚠️ POST_NOTIFICATIONS not granted');
      return const ScheduleResult(
        success: false,
        usedExactAlarm: false,
        error: 'POST_NOTIFICATIONS not granted',
      );
    }

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    return _schedule(id: id, title: title, body: body, scheduledDate: tzDate);
  }

  /// Daily reminders for selected weekdays.
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
      await _schedule(
        id: slotId,
        title: title,
        body: body,
        scheduledDate: scheduled,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
    _log('✅ Scheduled ${weekdays.length} weekly slot(s) at $hour:$minute');
  }

  /// Weekly reminder (single weekday + time).
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
    await _schedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  AndroidFlutterLocalNotificationsPlugin? _androidPlugin() => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  tz.TZDateTime _nextWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var c = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (c.weekday != weekday || !c.isAfter(now)) {
      c = c.add(const Duration(days: 1));
    }
    return c;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience helpers (backwards compat)
// ─────────────────────────────────────────────────────────────────────────────

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
