import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Salaat'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get navTracking;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get homeToday;

  /// No description provided for @homeNextPrayer.
  ///
  /// In en, this message translates to:
  /// **'NEXT PRAYER'**
  String get homeNextPrayer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @ameen.
  ///
  /// In en, this message translates to:
  /// **'Ameen'**
  String get ameen;

  /// No description provided for @reciterDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Adhan — Long'**
  String get reciterDefaultName;

  /// No description provided for @reciterSabahFakhryName.
  ///
  /// In en, this message translates to:
  /// **'Adhan — Sabah Fakhry (Long)'**
  String get reciterSabahFakhryName;

  /// No description provided for @reciterShortName.
  ///
  /// In en, this message translates to:
  /// **'Adhan — Short'**
  String get reciterShortName;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaTitle;

  /// No description provided for @qiblaCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Compass needs calibration — move your phone in a figure-8 pattern.'**
  String get qiblaCalibrate;

  /// No description provided for @qiblaFacing.
  ///
  /// In en, this message translates to:
  /// **'Facing the Qibla'**
  String get qiblaFacing;

  /// No description provided for @qiblaRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate until the Kaaba marker lines up with the top pointer'**
  String get qiblaRotate;

  /// No description provided for @qiblaNoCompass.
  ///
  /// In en, this message translates to:
  /// **'No compass sensor detected on this device.\nThe Qibla is {bearing}° from true North — use a physical compass and rotate to that bearing.'**
  String qiblaNoCompass(String bearing);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @calendarHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get calendarHijri;

  /// No description provided for @calendarGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get calendarGregorian;

  /// No description provided for @hijriYearSuffix.
  ///
  /// In en, this message translates to:
  /// **'AH'**
  String get hijriYearSuffix;

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Tracking'**
  String get trackingTitle;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String failedToLoad(String error);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @tabPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get tabPrayer;

  /// No description provided for @tabAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get tabAdhan;

  /// No description provided for @tabReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get tabReminders;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @sectionCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get sectionCalculationMethod;

  /// No description provided for @sectionMadhab.
  ///
  /// In en, this message translates to:
  /// **'Asr Calculation (Madhab)'**
  String get sectionMadhab;

  /// No description provided for @sectionManualAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Manual Adjustments'**
  String get sectionManualAdjustments;

  /// No description provided for @manualAdjustmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Nudge each prayer to match your local mosque. Applies daily until changed.'**
  String get manualAdjustmentsDesc;

  /// No description provided for @minutesValueLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutesValueLabel(String value);

  /// No description provided for @sectionAdhanSound.
  ///
  /// In en, this message translates to:
  /// **'Adhan Sound'**
  String get sectionAdhanSound;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Fires a real notification now, exactly as a prayer time would.'**
  String get testNotificationDesc;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test {mode} notification sent'**
  String testNotificationSent(String mode);

  /// No description provided for @sendTestNotificationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get sendTestNotificationTooltip;

  /// No description provided for @previewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTooltip;

  /// No description provided for @stopTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTooltip;

  /// No description provided for @overrideSilentTitle.
  ///
  /// In en, this message translates to:
  /// **'Play full Adhan even in Silent Mode'**
  String get overrideSilentTitle;

  /// No description provided for @overrideSilentDesc.
  ///
  /// In en, this message translates to:
  /// **'Like an alarm — bypasses your phone\'s silent/vibrate setting.'**
  String get overrideSilentDesc;

  /// No description provided for @overrideSilentDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Override Silent Mode?'**
  String get overrideSilentDialogTitle;

  /// No description provided for @overrideSilentDialogContent.
  ///
  /// In en, this message translates to:
  /// **'The full Adhan will play at full volume for prayers set to \"Full Adhan\", even if your phone is on silent or vibrate. Prayers set to Short Sound or Silent are not affected.'**
  String get overrideSilentDialogContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @sectionAzkarReminders.
  ///
  /// In en, this message translates to:
  /// **'Azkar Reminders'**
  String get sectionAzkarReminders;

  /// No description provided for @azkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Occasional dhikr reminders at random times through the day.'**
  String get azkarDesc;

  /// No description provided for @enableAzkarReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Azkar Reminders'**
  String get enableAzkarReminders;

  /// No description provided for @remindersPerDay.
  ///
  /// In en, this message translates to:
  /// **'Reminders per day'**
  String get remindersPerDay;

  /// No description provided for @testAzkarNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Azkar Notification'**
  String get testAzkarNotification;

  /// No description provided for @testAzkarDesc.
  ///
  /// In en, this message translates to:
  /// **'Fires a random azkar reminder now.'**
  String get testAzkarDesc;

  /// No description provided for @testAzkarSent.
  ///
  /// In en, this message translates to:
  /// **'Test azkar notification sent'**
  String get testAzkarSent;

  /// No description provided for @sendTestAzkarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send a test azkar notification'**
  String get sendTestAzkarTooltip;

  /// No description provided for @sectionFridayKahf.
  ///
  /// In en, this message translates to:
  /// **'Friday — Surah Al-Kahf'**
  String get sectionFridayKahf;

  /// No description provided for @fridayKahfDesc.
  ///
  /// In en, this message translates to:
  /// **'A weekly reminder every Friday morning to read سورة الكهف.'**
  String get fridayKahfDesc;

  /// No description provided for @enableFridayReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable Friday Reminder'**
  String get enableFridayReminder;

  /// No description provided for @testFridayReminder.
  ///
  /// In en, this message translates to:
  /// **'Test Friday Reminder'**
  String get testFridayReminder;

  /// No description provided for @testFridayDesc.
  ///
  /// In en, this message translates to:
  /// **'Fires the reminder now.'**
  String get testFridayDesc;

  /// No description provided for @testFridaySent.
  ///
  /// In en, this message translates to:
  /// **'Test Friday reminder sent'**
  String get testFridaySent;

  /// No description provided for @sendTestFridayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send a test Friday reminder'**
  String get sendTestFridayTooltip;

  /// No description provided for @sectionDailyAyah.
  ///
  /// In en, this message translates to:
  /// **'Daily Ayah'**
  String get sectionDailyAyah;

  /// No description provided for @dailyAyahDesc.
  ///
  /// In en, this message translates to:
  /// **'Show a random Quranic ayah each time you open the app.'**
  String get dailyAyahDesc;

  /// No description provided for @showAyahOnOpen.
  ///
  /// In en, this message translates to:
  /// **'Show Ayah on App Open'**
  String get showAyahOnOpen;

  /// No description provided for @sectionNextPrayerStatus.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer Notification'**
  String get sectionNextPrayerStatus;

  /// No description provided for @nextPrayerStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows a notification with the next prayer\'s name and time, updated automatically. You can dismiss it anytime — it\'ll come back the next time it\'s relevant.'**
  String get nextPrayerStatusDesc;

  /// No description provided for @enableNextPrayerStatus.
  ///
  /// In en, this message translates to:
  /// **'Show in Notification Bar'**
  String get enableNextPrayerStatus;

  /// No description provided for @statusNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{prayer} at {time}'**
  String statusNotificationBody(String prayer, String time);

  /// No description provided for @sectionYourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get sectionYourName;

  /// No description provided for @yourNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Used for the greeting on the home screen.'**
  String get yourNameDesc;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @madeByCredit.
  ///
  /// In en, this message translates to:
  /// **'Made by Abdallah Saeed 🍕'**
  String get madeByCredit;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersionLabel;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get checkingForUpdates;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get upToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates. Check your connection and try again.'**
  String get updateCheckFailed;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available. Update now?'**
  String updateAvailableBody(String version);

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get downloading;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the update. Please try again.'**
  String get updateDownloadFailed;

  /// No description provided for @updateInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the installer: {error}'**
  String updateInstallFailed(String error);

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get sectionLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @notificationsBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications Are Blocked'**
  String get notificationsBlockedTitle;

  /// No description provided for @notificationsBlockedContent.
  ///
  /// In en, this message translates to:
  /// **'This app doesn\'t have permission to show notifications, so nothing will appear or play — not even real prayer/Azkar reminders. Enable notifications for My Salaat in system settings, then try the test again.'**
  String get notificationsBlockedContent;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @methodMuslimWorldLeague.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMuslimWorldLeague;

  /// No description provided for @methodEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get methodEgyptian;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In en, this message translates to:
  /// **'Umm al-Qura'**
  String get methodUmmAlQura;

  /// No description provided for @methodIsna.
  ///
  /// In en, this message translates to:
  /// **'Islamic Society of North America (ISNA)'**
  String get methodIsna;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'University of Islamic Sciences, Karachi'**
  String get methodKarachi;

  /// No description provided for @methodDubai.
  ///
  /// In en, this message translates to:
  /// **'Dubai'**
  String get methodDubai;

  /// No description provided for @methodKuwait.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get methodKuwait;

  /// No description provided for @methodQatar.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get methodQatar;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get methodSingapore;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get methodTehran;

  /// No description provided for @methodTurkiye.
  ///
  /// In en, this message translates to:
  /// **'Turkiye (Diyanet)'**
  String get methodTurkiye;

  /// No description provided for @methodMoonsightingCommittee.
  ///
  /// In en, this message translates to:
  /// **'Moonsighting Committee'**
  String get methodMoonsightingCommittee;

  /// No description provided for @methodNorthAmerica.
  ///
  /// In en, this message translates to:
  /// **'North America'**
  String get methodNorthAmerica;

  /// No description provided for @methodOther.
  ///
  /// In en, this message translates to:
  /// **'Other (default)'**
  String get methodOther;

  /// No description provided for @madhabShafi.
  ///
  /// In en, this message translates to:
  /// **'Shafi (standard)'**
  String get madhabShafi;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @soundModeFull.
  ///
  /// In en, this message translates to:
  /// **'Full Adhan'**
  String get soundModeFull;

  /// No description provided for @soundModeShort.
  ///
  /// In en, this message translates to:
  /// **'Short Sound'**
  String get soundModeShort;

  /// No description provided for @soundModeSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent (Vibrate)'**
  String get soundModeSilent;

  /// No description provided for @soundModeFullCompact.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get soundModeFullCompact;

  /// No description provided for @soundModeShortCompact.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get soundModeShortCompact;

  /// No description provided for @soundModeSilentCompact.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get soundModeSilentCompact;

  /// No description provided for @statusPrayed.
  ///
  /// In en, this message translates to:
  /// **'Prayed'**
  String get statusPrayed;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'Prayed Late'**
  String get statusLate;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @notificationPrayerTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} Prayer Time'**
  String notificationPrayerTimeTitle(String prayer);

  /// No description provided for @notificationPrayerTimeBodySilent.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for {prayer} prayer.'**
  String notificationPrayerTimeBodySilent(String prayer);

  /// No description provided for @notificationPrayerTimeBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s time for {prayer} prayer — {reciter}'**
  String notificationPrayerTimeBody(String prayer, String reciter);

  /// No description provided for @notificationTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBodySilent.
  ///
  /// In en, this message translates to:
  /// **'This is what a Silent prayer notification looks like.'**
  String get notificationTestBodySilent;

  /// No description provided for @notificationTestBody.
  ///
  /// In en, this message translates to:
  /// **'This is what a {mode} prayer notification sounds like.'**
  String notificationTestBody(String mode);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
