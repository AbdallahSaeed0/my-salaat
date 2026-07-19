import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/generated/app_localizations.dart';
import '../models/adhan_sound_mode.dart';
import '../models/azkar.dart';
import 'prayer_time_service.dart';

/// Initializes flutter_local_notifications and schedules/cancels the
/// per-prayer local notifications for a given day's prayer times.
///
/// Scheduling is only supported by the plugin on Android/iOS/macOS; other
/// targets (e.g. Windows/Linux desktop, used for local dev) are no-ops.
///
/// Sound playback for a fired notification is handled entirely by the OS
/// via the Android notification channel's sound resource (or the iOS
/// Darwin notification's `sound` file) — not by an in-app audio player —
/// since that's the only way it reliably plays while the app is closed.
/// Android channel properties (sound, vibration, audio usage) are immutable
/// once created, so each distinct (prayer, mode, reciter, override-silent)
/// combination gets its own channel id; changing a setting creates a fresh
/// channel rather than mutating the old one.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static bool get _supportsScheduling =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    // A dedicated white-silhouette-on-transparent drawable — Android always
    // strips color from the small icon (shown top-left) and renders only
    // its alpha shape, so passing the full-color launcher icon here just
    // shows a solid tinted blob instead of the logo's silhouette.
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Android 13+ requires the POST_NOTIFICATIONS runtime permission, and
    // iOS requires explicit permission too — without this, show()/
    // zonedSchedule() silently do nothing (no exception, no notification).
    await requestPermissions();

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidPlugin?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 12/12L require the user to manually grant "Alarms & reminders"
    // in system settings before an exact alarm (zonedSchedule with
    // exactAllowWhileIdle) will actually fire — without it, the OS silently
    // downgrades or drops the scheduled alarm instead of throwing. Android
    // 13+ auto-grants this for sideloaded/debug installs, and
    // canScheduleExactNotifications() reflects both cases, so this is a
    // no-op there.
    final canScheduleExact = await androidPlugin?.canScheduleExactNotifications();
    if (canScheduleExact == false) {
      await androidPlugin?.requestExactAlarmsPermission();
    }

    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  // Bumped whenever a change means previously-created channels on a user's
  // device could be stuck with stale/broken settings (e.g. a sound resource
  // that pointed at different audio in an earlier build). Baking the version
  // into the id makes the app abandon the old channel and create a fresh one
  // instead of silently reusing a possibly-broken one — createNotificationChannel()
  // is a no-op on an id that already exists, so this is the only reliable way
  // to self-heal without forcing a delete+recreate (and losing user channel
  // customization) on every single app start.
  static const _channelSchemaVersion = 2;

  String _channelId(String key, AdhanSoundMode mode, {required String reciterId, required bool overrideSilentMode}) {
    switch (mode) {
      case AdhanSoundMode.full:
        return 'prayer_${key}_full_${reciterId}_${overrideSilentMode ? 'alarm' : 'notif'}_v$_channelSchemaVersion';
      case AdhanSoundMode.short:
        return 'prayer_${key}_short_v$_channelSchemaVersion';
      case AdhanSoundMode.silent:
        return 'prayer_${key}_silent_v$_channelSchemaVersion';
    }
  }

  Future<void> _ensureChannel(
    String key,
    String label,
    AdhanSoundMode mode, {
    required Reciter reciter,
    required bool overrideSilentMode,
    bool forceRecreate = false,
  }) async {
    final id = _channelId(key, mode, reciterId: reciter.id, overrideSilentMode: overrideSilentMode);
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    // Android locks a channel's sound/vibration/importance once created —
    // createNotificationChannel() silently no-ops on an existing id even if
    // the properties below differ. For the "test" channels specifically we
    // want every tap to reflect the *current* settings, so drop and rebuild
    // it rather than risk it being stuck from an earlier test.
    if (forceRecreate) {
      await androidPlugin?.deleteNotificationChannel(id);
    }
    late final AndroidNotificationChannel channel;
    switch (mode) {
      case AdhanSoundMode.full:
        channel = AndroidNotificationChannel(
          id,
          '$label — Full Adhan',
          description: 'Plays the full Adhan for $label',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(reciter.androidRawResource),
          audioAttributesUsage: overrideSilentMode ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
        );
      case AdhanSoundMode.short:
        channel = AndroidNotificationChannel(
          id,
          '$label — Short Sound',
          description: 'Plays a short chime for $label',
          importance: Importance.max,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(shortSoundAndroidRawResource),
        );
      case AdhanSoundMode.silent:
        channel = AndroidNotificationChannel(
          id,
          '$label — Silent',
          description: 'Vibrate only for $label',
          importance: Importance.max,
          playSound: false,
          enableVibration: true,
        );
    }
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Schedules one notification per prayer in [times], replacing any
  /// previously scheduled prayer notifications. Times in the past are
  /// skipped. [soundModes]/[reciter]/[overrideSilentMode] control how each
  /// prayer's notification sounds — see the class doc for why this maps to
  /// distinct notification channels rather than one shared channel.
  Future<void> scheduleDailyPrayerNotifications(
    Map<DailyPrayer, DateTime> times, {
    required Map<DailyPrayer, AdhanSoundMode> soundModes,
    required Reciter reciter,
    required bool overrideSilentMode,
    required Locale locale,
  }) async {
    if (!_supportsScheduling) return;
    await cancelAllPrayerNotifications();

    final l10n = lookupAppLocalizations(locale);
    final now = tz.TZDateTime.now(tz.local);
    for (final prayer in DailyPrayer.values) {
      final localTime = times[prayer]!;
      final scheduled = tz.TZDateTime.from(localTime, tz.local);
      if (scheduled.isBefore(now)) continue;

      final prayerLabel = prayer.label(l10n);
      final mode = soundModes[prayer] ?? AdhanSoundMode.full;
      await _ensureChannel(prayer.name, prayerLabel, mode, reciter: reciter, overrideSilentMode: overrideSilentMode);
      final channelId = _channelId(prayer.name, mode, reciterId: reciter.id, overrideSilentMode: overrideSilentMode);

      final iosSoundFile = switch (mode) {
        AdhanSoundMode.full => reciter.assetPath.split('/').last,
        AdhanSoundMode.short => shortSoundAssetPath.split('/').last,
        AdhanSoundMode.silent => null,
      };

      await _plugin.zonedSchedule(
        _notificationId(prayer),
        l10n.notificationPrayerTimeTitle(prayerLabel),
        mode == AdhanSoundMode.silent
            ? l10n.notificationPrayerTimeBodySilent(prayerLabel)
            : l10n.notificationPrayerTimeBody(prayerLabel, reciter.localizedName(l10n)),
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            '$prayerLabel notifications',
            channelDescription: 'Notifications for $prayerLabel',
            importance: Importance.max,
            priority: Priority.high,
            playSound: mode != AdhanSoundMode.silent,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: mode != AdhanSoundMode.silent,
            sound: iosSoundFile,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Whether the OS will actually display notifications from this app right
  /// now — false if the user denied (or never granted) the notification
  /// permission. `null` on platforms where this can't be checked (assume ok).
  Future<bool> areNotificationsEnabled() async {
    final androidResult = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return androidResult ?? true;
  }

  /// Fires an immediate notification using the exact same channel/sound
  /// setup a real prayer notification would use, so the user can confirm
  /// the Adhan actually plays (and how it behaves in silent mode) without
  /// waiting for a real prayer time.
  ///
  /// Returns false (without throwing) if notifications are blocked at the OS
  /// level — callers should check this and direct the user to system
  /// settings, since `show()` otherwise fails completely silently.
  Future<bool> sendTestNotification({
    required AdhanSoundMode mode,
    required Reciter reciter,
    required bool overrideSilentMode,
    required Locale locale,
  }) async {
    if (!_supportsScheduling) return false;
    if (!await areNotificationsEnabled()) return false;

    final l10n = lookupAppLocalizations(locale);
    const key = 'test';
    const label = 'Test';
    await _ensureChannel(key, label, mode, reciter: reciter, overrideSilentMode: overrideSilentMode, forceRecreate: true);
    final channelId = _channelId(key, mode, reciterId: reciter.id, overrideSilentMode: overrideSilentMode);

    final iosSoundFile = switch (mode) {
      AdhanSoundMode.full => reciter.assetPath.split('/').last,
      AdhanSoundMode.short => shortSoundAssetPath.split('/').last,
      AdhanSoundMode.silent => null,
    };

    await _plugin.show(
      9999,
      l10n.notificationTestTitle,
      mode == AdhanSoundMode.silent ? l10n.notificationTestBodySilent : l10n.notificationTestBody(mode.label(l10n)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          '$label notifications',
          channelDescription: 'Test notification for $label',
          importance: Importance.max,
          priority: Priority.high,
          playSound: mode != AdhanSoundMode.silent,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: mode != AdhanSoundMode.silent,
          sound: iosSoundFile,
        ),
      ),
    );
    return true;
  }

  Future<void> cancelAllPrayerNotifications() async {
    if (!_supportsScheduling) return;
    for (final prayer in DailyPrayer.values) {
      await _plugin.cancel(_notificationId(prayer));
    }
  }

  int _notificationId(DailyPrayer prayer) => 1000 + prayer.index;

  static const _azkarChannelId = 'azkar_reminders';
  static const _maxAzkarPerDay = 12;
  int _azkarNotificationId(int index) => 3000 + index;

  Future<void> _ensureAzkarChannel({bool forceRecreate = false}) async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (forceRecreate) {
      await androidPlugin?.deleteNotificationChannel(_azkarChannelId);
    }
    const channel = AndroidNotificationChannel(
      _azkarChannelId,
      'Azkar Reminders',
      description: 'Occasional dhikr/azkar reminders through the day',
      importance: Importance.defaultImportance,
      playSound: true,
    );
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Schedules [count] azkar reminders at random times today, spread across
  /// the [windowStartHour]–[windowEndHour] window (default a waking-hours
  /// window) so they don't cluster together. Each pick is a random entry
  /// from [azkarPool], without repeats within the same day where possible.
  /// Uses inexact scheduling — azkar reminders don't need to-the-second
  /// timing, so this avoids needing the exact-alarm permission that prayer
  /// notifications rely on.
  Future<void> scheduleRandomAzkarNotifications({
    required int count,
    int windowStartHour = 7,
    int windowEndHour = 22,
  }) async {
    if (!_supportsScheduling) return;
    await cancelAllAzkarNotifications();
    if (count <= 0) return;

    await _ensureAzkarChannel();

    final now = tz.TZDateTime.now(tz.local);
    final windowStart = tz.TZDateTime(tz.local, now.year, now.month, now.day, windowStartHour);
    final windowEnd = tz.TZDateTime(tz.local, now.year, now.month, now.day, windowEndHour);
    final rangeStart = now.isAfter(windowStart) ? now : windowStart;
    if (!rangeStart.isBefore(windowEnd)) return;

    final totalSeconds = windowEnd.difference(rangeStart).inSeconds;
    final segmentSeconds = totalSeconds / count;
    final random = Random();
    final shuffledAzkar = List.of(azkarPool)..shuffle(random);

    for (var i = 0; i < count; i++) {
      final segmentStartOffset = (segmentSeconds * i).round();
      final segmentEndOffset = (segmentSeconds * (i + 1)).round();
      final offsetSeconds = segmentStartOffset + random.nextInt((segmentEndOffset - segmentStartOffset).clamp(1, 1 << 30));
      final scheduled = rangeStart.add(Duration(seconds: offsetSeconds));
      final azkar = shuffledAzkar[i % shuffledAzkar.length];

      await _plugin.zonedSchedule(
        _azkarNotificationId(i),
        null,
        azkar.arabic,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _azkarChannelId,
            'Azkar Reminders',
            channelDescription: 'Occasional dhikr/azkar reminders through the day',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: false, presentSound: true),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAllAzkarNotifications() async {
    if (!_supportsScheduling) return;
    for (var i = 0; i < _maxAzkarPerDay; i++) {
      await _plugin.cancel(_azkarNotificationId(i));
    }
  }

  /// Fires one random azkar notification immediately, so the user can
  /// preview what these reminders look like without waiting. Returns false
  /// if notifications are blocked at the OS level.
  Future<bool> sendTestAzkarNotification() async {
    if (!_supportsScheduling) return false;
    if (!await areNotificationsEnabled()) return false;

    await _ensureAzkarChannel(forceRecreate: true);
    final azkar = azkarPool[Random().nextInt(azkarPool.length)];
    await _plugin.show(
      3999,
      null,
      azkar.arabic,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _azkarChannelId,
          'Azkar Reminders',
          channelDescription: 'Occasional dhikr/azkar reminders through the day',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: false, presentSound: true),
      ),
    );
    return true;
  }

  static const _kahfChannelId = 'friday_kahf_reminder';
  static const _kahfTitle = 'Friday Reminder';
  static const _kahfBody = "It's Friday — a good time to read Surah Al-Kahf (سورة الكهف).";
  int _kahfNotificationId() => 4000;

  Future<void> _ensureKahfChannel({bool forceRecreate = false}) async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (forceRecreate) {
      await androidPlugin?.deleteNotificationChannel(_kahfChannelId);
    }
    const channel = AndroidNotificationChannel(
      _kahfChannelId,
      'Friday Al-Kahf Reminder',
      description: 'Weekly reminder to read Surah Al-Kahf on Fridays',
      importance: Importance.max,
      playSound: true,
    );
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// Schedules (or cancels, if [enabled] is false) a weekly reminder that
  /// fires every Friday at [hour] to read Surah Al-Kahf.
  Future<void> scheduleFridayKahfReminder({required bool enabled, int hour = 8}) async {
    if (!_supportsScheduling) return;
    await cancelFridayKahfReminder();
    if (!enabled) return;

    await _ensureKahfChannel();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (scheduled.weekday != DateTime.friday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _kahfNotificationId(),
      _kahfTitle,
      _kahfBody,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kahfChannelId,
          'Friday Al-Kahf Reminder',
          channelDescription: 'Weekly reminder to read Surah Al-Kahf on Fridays',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelFridayKahfReminder() async {
    if (!_supportsScheduling) return;
    await _plugin.cancel(_kahfNotificationId());
  }

  /// Fires the Friday Al-Kahf reminder immediately, so the user can preview
  /// it without waiting for Friday. Returns false if notifications are
  /// blocked at the OS level.
  Future<bool> sendTestKahfReminder() async {
    if (!_supportsScheduling) return false;
    if (!await areNotificationsEnabled()) return false;

    await _ensureKahfChannel(forceRecreate: true);
    await _plugin.show(
      4999,
      _kahfTitle,
      _kahfBody,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kahfChannelId,
          'Friday Al-Kahf Reminder',
          channelDescription: 'Weekly reminder to read Surah Al-Kahf on Fridays',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
    return true;
  }

  static const _statusChannelId = 'next_prayer_status';
  int get _statusNotificationId => 6000;

  Future<void> _ensureStatusChannel() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    const channel = AndroidNotificationChannel(
      _statusChannelId,
      'Next Prayer Status',
      description: 'A dismissible, updating notification showing the next prayer',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await androidPlugin?.createNotificationChannel(channel);
  }

  /// [countdownTarget] drives Android's native chronometer: given a future
  /// timestamp, the OS itself renders a live ticking countdown in the
  /// notification with no repeated updates from the app — just a "when"
  /// timestamp and two flags. Not supported on iOS; there it's a static
  /// notification with no visible countdown.
  NotificationDetails _statusNotificationDetails(DateTime countdownTarget) => NotificationDetails(
        android: AndroidNotificationDetails(
          _statusChannelId,
          'Next Prayer Status',
          channelDescription: 'A dismissible, updating notification showing the next prayer',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
          enableVibration: false,
          onlyAlertOnce: true,
          ongoing: false,
          showWhen: true,
          when: countdownTarget.millisecondsSinceEpoch,
          usesChronometer: true,
          chronometerCountDown: true,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: false, presentSound: false),
      );

  /// Shows (or replaces) the "next prayer" status notification immediately,
  /// with a live countdown ticking down to [time] (see
  /// [_statusNotificationDetails]). Freely dismissible — it simply
  /// reappears the next time this or [scheduleNextPrayerStatusUpdate] runs.
  Future<void> showNextPrayerStatus({
    required DailyPrayer prayer,
    required DateTime time,
    required Locale locale,
  }) async {
    if (!_supportsScheduling) return;
    final l10n = lookupAppLocalizations(locale);
    await _ensureStatusChannel();
    final timeText = DateFormat.jm(locale.languageCode).format(time);
    await _plugin.show(
      _statusNotificationId,
      l10n.homeNextPrayer,
      l10n.statusNotificationBody(prayer.label(l10n), timeText),
      _statusNotificationDetails(time),
    );
  }

  /// Arms exactly one future update of the status notification, timed at
  /// [currentNextTime] (when the current "next prayer" arrives), showing
  /// what becomes next *after* that — [followingPrayer]/[followingTime].
  ///
  /// Only one step is scheduled at a time (not all five prayer transitions)
  /// because Android's alarm scheduling replaces any existing pending alarm
  /// that shares a notification id the moment a new one is armed — chaining
  /// multiple future updates under one id would silently cancel all but the
  /// last. This single step self-corrects every time the app is opened
  /// (each open re-arms the next step from wherever "now" actually is), so
  /// the notification is always accurate on open and auto-advances through
  /// the very next transition even if the app stays closed.
  Future<void> scheduleNextPrayerStatusUpdate({
    required DateTime currentNextTime,
    required DailyPrayer followingPrayer,
    required DateTime followingTime,
    required Locale locale,
  }) async {
    if (!_supportsScheduling) return;
    final scheduled = tz.TZDateTime.from(currentNextTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (!scheduled.isAfter(now)) return;

    final l10n = lookupAppLocalizations(locale);
    await _ensureStatusChannel();
    final timeText = DateFormat.jm(locale.languageCode).format(followingTime);

    await _plugin.zonedSchedule(
      _statusNotificationId,
      l10n.homeNextPrayer,
      l10n.statusNotificationBody(followingPrayer.label(l10n), timeText),
      scheduled,
      _statusNotificationDetails(followingTime),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNextPrayerStatus() async {
    if (!_supportsScheduling) return;
    await _plugin.cancel(_statusNotificationId);
  }
}
