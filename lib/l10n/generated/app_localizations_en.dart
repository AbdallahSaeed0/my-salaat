// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Salaat';

  @override
  String get navHome => 'Home';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navTracking => 'Tracking';

  @override
  String get homeToday => 'TODAY';

  @override
  String get homeNextPrayer => 'NEXT PRAYER';

  @override
  String get retry => 'Retry';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get ameen => 'Ameen';

  @override
  String get reciterDefaultName => 'Adhan — Long';

  @override
  String get reciterSabahFakhryName => 'Adhan — Sabah Fakhry (Long)';

  @override
  String get reciterShortName => 'Adhan — Short';

  @override
  String get qiblaTitle => 'Qibla Direction';

  @override
  String get qiblaCalibrate =>
      'Compass needs calibration — move your phone in a figure-8 pattern.';

  @override
  String get qiblaFacing => 'Facing the Qibla';

  @override
  String get qiblaRotate =>
      'Rotate until the Kaaba marker lines up with the top pointer';

  @override
  String qiblaNoCompass(String bearing) {
    return 'No compass sensor detected on this device.\nThe Qibla is $bearing° from true North — use a physical compass and rotate to that bearing.';
  }

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get today => 'Today';

  @override
  String get calendarHijri => 'Hijri';

  @override
  String get calendarGregorian => 'Gregorian';

  @override
  String get hijriYearSuffix => 'AH';

  @override
  String get trackingTitle => 'Prayer Tracking';

  @override
  String get thisMonth => 'This Month';

  @override
  String get dayStreak => 'day streak';

  @override
  String failedToLoad(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get tabPrayer => 'Prayer';

  @override
  String get tabAdhan => 'Adhan';

  @override
  String get tabReminders => 'Reminders';

  @override
  String get tabProfile => 'Profile';

  @override
  String get sectionCalculationMethod => 'Calculation Method';

  @override
  String get sectionMadhab => 'Asr Calculation (Madhab)';

  @override
  String get sectionManualAdjustments => 'Manual Adjustments';

  @override
  String get manualAdjustmentsDesc =>
      'Nudge each prayer to match your local mosque. Applies daily until changed.';

  @override
  String minutesValueLabel(String value) {
    return '$value min';
  }

  @override
  String get sectionAdhanSound => 'Adhan Sound';

  @override
  String get testNotificationTitle => 'Test Notification';

  @override
  String get testNotificationDesc =>
      'Fires a real notification now, exactly as a prayer time would.';

  @override
  String testNotificationSent(String mode) {
    return 'Test $mode notification sent';
  }

  @override
  String get sendTestNotificationTooltip => 'Send a test notification';

  @override
  String get previewTooltip => 'Preview';

  @override
  String get stopTooltip => 'Stop';

  @override
  String get overrideSilentTitle => 'Play full Adhan even in Silent Mode';

  @override
  String get overrideSilentDesc =>
      'Like an alarm — bypasses your phone\'s silent/vibrate setting.';

  @override
  String get overrideSilentDialogTitle => 'Override Silent Mode?';

  @override
  String get overrideSilentDialogContent =>
      'The full Adhan will play at full volume for prayers set to \"Full Adhan\", even if your phone is on silent or vibrate. Prayers set to Short Sound or Silent are not affected.';

  @override
  String get cancel => 'Cancel';

  @override
  String get allow => 'Allow';

  @override
  String get sectionAzkarReminders => 'Azkar Reminders';

  @override
  String get azkarDesc =>
      'Occasional dhikr reminders at random times through the day.';

  @override
  String get enableAzkarReminders => 'Enable Azkar Reminders';

  @override
  String get remindersPerDay => 'Reminders per day';

  @override
  String get testAzkarNotification => 'Test Azkar Notification';

  @override
  String get testAzkarDesc => 'Fires a random azkar reminder now.';

  @override
  String get testAzkarSent => 'Test azkar notification sent';

  @override
  String get sendTestAzkarTooltip => 'Send a test azkar notification';

  @override
  String get sectionFridayKahf => 'Friday — Surah Al-Kahf';

  @override
  String get fridayKahfDesc =>
      'A weekly reminder every Friday morning to read سورة الكهف.';

  @override
  String get enableFridayReminder => 'Enable Friday Reminder';

  @override
  String get testFridayReminder => 'Test Friday Reminder';

  @override
  String get testFridayDesc => 'Fires the reminder now.';

  @override
  String get testFridaySent => 'Test Friday reminder sent';

  @override
  String get sendTestFridayTooltip => 'Send a test Friday reminder';

  @override
  String get sectionDailyAyah => 'Daily Ayah';

  @override
  String get dailyAyahDesc =>
      'Show a random Quranic ayah each time you open the app.';

  @override
  String get showAyahOnOpen => 'Show Ayah on App Open';

  @override
  String get sectionNextPrayerStatus => 'Next Prayer Notification';

  @override
  String get nextPrayerStatusDesc =>
      'Shows a notification with the next prayer\'s name and time, updated automatically. You can dismiss it anytime — it\'ll come back the next time it\'s relevant.';

  @override
  String get enableNextPrayerStatus => 'Show in Notification Bar';

  @override
  String statusNotificationBody(String prayer, String time) {
    return '$prayer at $time';
  }

  @override
  String get sectionYourName => 'Your Name';

  @override
  String get yourNameDesc => 'Used for the greeting on the home screen.';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get sectionAbout => 'About';

  @override
  String get madeByCredit => 'Made by Abdallah Saeed 🍕';

  @override
  String get appVersionLabel => 'App Version';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get checkingForUpdates => 'Checking for updates…';

  @override
  String get upToDate => 'You\'re up to date';

  @override
  String get updateCheckFailed =>
      'Couldn\'t check for updates. Check your connection and try again.';

  @override
  String get updateAvailableTitle => 'Update Available';

  @override
  String updateAvailableBody(String version) {
    return 'Version $version is available. Update now?';
  }

  @override
  String get later => 'Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String get downloading => 'Downloading update…';

  @override
  String get updateDownloadFailed =>
      'Couldn\'t download the update. Please try again.';

  @override
  String updateInstallFailed(String error) {
    return 'Couldn\'t open the installer: $error';
  }

  @override
  String get sectionLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get notificationsBlockedTitle => 'Notifications Are Blocked';

  @override
  String get notificationsBlockedContent =>
      'This app doesn\'t have permission to show notifications, so nothing will appear or play — not even real prayer/Azkar reminders. Enable notifications for My Salaat in system settings, then try the test again.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get methodMuslimWorldLeague => 'Muslim World League';

  @override
  String get methodEgyptian => 'Egyptian General Authority';

  @override
  String get methodUmmAlQura => 'Umm al-Qura';

  @override
  String get methodIsna => 'Islamic Society of North America (ISNA)';

  @override
  String get methodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get methodDubai => 'Dubai';

  @override
  String get methodKuwait => 'Kuwait';

  @override
  String get methodQatar => 'Qatar';

  @override
  String get methodSingapore => 'Singapore';

  @override
  String get methodTehran => 'Tehran';

  @override
  String get methodTurkiye => 'Turkiye (Diyanet)';

  @override
  String get methodMoonsightingCommittee => 'Moonsighting Committee';

  @override
  String get methodNorthAmerica => 'North America';

  @override
  String get methodOther => 'Other (default)';

  @override
  String get madhabShafi => 'Shafi (standard)';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get soundModeFull => 'Full Adhan';

  @override
  String get soundModeShort => 'Short Sound';

  @override
  String get soundModeSilent => 'Silent (Vibrate)';

  @override
  String get soundModeFullCompact => 'Full';

  @override
  String get soundModeShortCompact => 'Short';

  @override
  String get soundModeSilentCompact => 'Silent';

  @override
  String get statusPrayed => 'Prayed';

  @override
  String get statusLate => 'Prayed Late';

  @override
  String get statusMissed => 'Missed';

  @override
  String notificationPrayerTimeTitle(String prayer) {
    return '$prayer Prayer Time';
  }

  @override
  String notificationPrayerTimeBodySilent(String prayer) {
    return 'It\'s time for $prayer prayer.';
  }

  @override
  String notificationPrayerTimeBody(String prayer, String reciter) {
    return 'It\'s time for $prayer prayer — $reciter';
  }

  @override
  String get notificationTestTitle => 'Test Notification';

  @override
  String get notificationTestBodySilent =>
      'This is what a Silent prayer notification looks like.';

  @override
  String notificationTestBody(String mode) {
    return 'This is what a $mode prayer notification sounds like.';
  }
}
