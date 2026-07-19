// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'صلاتي';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navTracking => 'المتابعة';

  @override
  String get homeToday => 'اليوم';

  @override
  String get homeNextPrayer => 'الصلاة القادمة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get settingsTooltip => 'الإعدادات';

  @override
  String get ameen => 'آمين';

  @override
  String get reciterDefaultName => 'أذان — طويل';

  @override
  String get reciterSabahFakhryName => 'أذان — صباح فخري (طويل)';

  @override
  String get reciterShortName => 'أذان — قصير';

  @override
  String get qiblaTitle => 'اتجاه القبلة';

  @override
  String get qiblaCalibrate =>
      'البوصلة تحتاج إلى معايرة — حرّك هاتفك على شكل رقم 8.';

  @override
  String get qiblaFacing => 'أنت متجه نحو القبلة';

  @override
  String get qiblaRotate => 'استدر حتى تتوافق علامة الكعبة مع المؤشر العلوي';

  @override
  String qiblaNoCompass(String bearing) {
    return 'لم يتم العثور على حساس بوصلة في هذا الجهاز.\nاتجاه القبلة هو $bearing° من الشمال الحقيقي — استخدم بوصلة عادية واستدر إلى هذا الاتجاه.';
  }

  @override
  String get calendarTitle => 'التقويم';

  @override
  String get today => 'اليوم';

  @override
  String get calendarHijri => 'هجري';

  @override
  String get calendarGregorian => 'ميلادي';

  @override
  String get hijriYearSuffix => 'هـ';

  @override
  String get trackingTitle => 'متابعة الصلاة';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get dayStreak => 'يوم متتالي';

  @override
  String failedToLoad(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get tabPrayer => 'الصلاة';

  @override
  String get tabAdhan => 'الأذان';

  @override
  String get tabReminders => 'التذكيرات';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get sectionCalculationMethod => 'طريقة الحساب';

  @override
  String get sectionMadhab => 'حساب العصر (المذهب)';

  @override
  String get sectionManualAdjustments => 'التعديلات اليدوية';

  @override
  String get manualAdjustmentsDesc =>
      'اضبط كل صلاة لتطابق مسجدك المحلي. يُطبَّق يوميًا حتى تغييره.';

  @override
  String minutesValueLabel(String value) {
    return '$value د';
  }

  @override
  String get sectionAdhanSound => 'صوت الأذان';

  @override
  String get testNotificationTitle => 'اختبار الإشعار';

  @override
  String get testNotificationDesc =>
      'يرسل إشعارًا حقيقيًا الآن، تمامًا كما يحدث عند دخول وقت الصلاة.';

  @override
  String testNotificationSent(String mode) {
    return 'تم إرسال إشعار اختبار $mode';
  }

  @override
  String get sendTestNotificationTooltip => 'إرسال إشعار تجريبي';

  @override
  String get previewTooltip => 'معاينة';

  @override
  String get stopTooltip => 'إيقاف';

  @override
  String get overrideSilentTitle => 'تشغيل الأذان كاملاً حتى في الوضع الصامت';

  @override
  String get overrideSilentDesc =>
      'مثل المنبه — يتجاوز وضع الصامت/الاهتزاز في هاتفك.';

  @override
  String get overrideSilentDialogTitle => 'تجاوز الوضع الصامت؟';

  @override
  String get overrideSilentDialogContent =>
      'سيتم تشغيل الأذان الكامل بصوت عالٍ للصلوات المضبوطة على \"الأذان الكامل\"، حتى لو كان هاتفك في وضع الصامت أو الاهتزاز. الصلوات المضبوطة على صوت قصير أو صامت لن تتأثر.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get allow => 'سماح';

  @override
  String get sectionAzkarReminders => 'تذكيرات الأذكار';

  @override
  String get azkarDesc => 'تذكيرات أذكار عرضية في أوقات عشوائية خلال اليوم.';

  @override
  String get enableAzkarReminders => 'تفعيل تذكيرات الأذكار';

  @override
  String get remindersPerDay => 'عدد التذكيرات يوميًا';

  @override
  String get testAzkarNotification => 'اختبار إشعار الأذكار';

  @override
  String get testAzkarDesc => 'يرسل تذكير أذكار عشوائي الآن.';

  @override
  String get testAzkarSent => 'تم إرسال إشعار أذكار تجريبي';

  @override
  String get sendTestAzkarTooltip => 'إرسال إشعار أذكار تجريبي';

  @override
  String get sectionFridayKahf => 'الجمعة — سورة الكهف';

  @override
  String get fridayKahfDesc => 'تذكير أسبوعي كل صباح جمعة بقراءة سورة الكهف.';

  @override
  String get enableFridayReminder => 'تفعيل تذكير الجمعة';

  @override
  String get testFridayReminder => 'اختبار تذكير الجمعة';

  @override
  String get testFridayDesc => 'يرسل التذكير الآن.';

  @override
  String get testFridaySent => 'تم إرسال تذكير الجمعة التجريبي';

  @override
  String get sendTestFridayTooltip => 'إرسال تذكير جمعة تجريبي';

  @override
  String get sectionDailyAyah => 'آية اليوم';

  @override
  String get dailyAyahDesc =>
      'عرض آية قرآنية عشوائية في كل مرة تفتح فيها التطبيق.';

  @override
  String get showAyahOnOpen => 'عرض آية عند فتح التطبيق';

  @override
  String get sectionNextPrayerStatus => 'إشعار الصلاة القادمة';

  @override
  String get nextPrayerStatusDesc =>
      'يعرض إشعارًا باسم الصلاة القادمة ووقتها، ويُحدَّث تلقائيًا. يمكنك إزالته في أي وقت — سيظهر مجددًا عند الحاجة.';

  @override
  String get enableNextPrayerStatus => 'إظهار في شريط الإشعارات';

  @override
  String statusNotificationBody(String prayer, String time) {
    return '$prayer الساعة $time';
  }

  @override
  String get sectionYourName => 'اسمك';

  @override
  String get yourNameDesc => 'يُستخدم للتحية في الشاشة الرئيسية.';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get sectionAbout => 'حول التطبيق';

  @override
  String get madeByCredit => 'صُنع بواسطة عبدالله سعيد 🍕';

  @override
  String get appVersionLabel => 'إصدار التطبيق';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get checkingForUpdates => 'جارٍ التحقق من التحديثات…';

  @override
  String get upToDate => 'التطبيق محدَّث بالفعل';

  @override
  String get updateCheckFailed =>
      'تعذّر التحقق من التحديثات. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get updateAvailableTitle => 'يتوفر تحديث';

  @override
  String updateAvailableBody(String version) {
    return 'الإصدار $version متوفر الآن. هل تريد التحديث؟';
  }

  @override
  String get later => 'لاحقًا';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get downloading => 'جارٍ تنزيل التحديث…';

  @override
  String get updateDownloadFailed => 'تعذّر تنزيل التحديث. حاول مرة أخرى.';

  @override
  String updateInstallFailed(String error) {
    return 'تعذّر فتح المثبِّت: $error';
  }

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get notificationsBlockedTitle => 'الإشعارات محظورة';

  @override
  String get notificationsBlockedContent =>
      'لا يملك هذا التطبيق إذن عرض الإشعارات، لذلك لن يظهر أو يُشغَّل أي شيء — ولا حتى تذكيرات الصلاة أو الأذكار الحقيقية. فعّل الإشعارات لتطبيق صلاتي من إعدادات النظام، ثم أعد المحاولة.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get methodMuslimWorldLeague => 'رابطة العالم الإسلامي';

  @override
  String get methodEgyptian => 'الهيئة المصرية العامة للمساحة';

  @override
  String get methodUmmAlQura => 'أم القرى';

  @override
  String get methodIsna => 'الجمعية الإسلامية لأمريكا الشمالية';

  @override
  String get methodKarachi => 'جامعة العلوم الإسلامية، كراتشي';

  @override
  String get methodDubai => 'دبي';

  @override
  String get methodKuwait => 'الكويت';

  @override
  String get methodQatar => 'قطر';

  @override
  String get methodSingapore => 'سنغافورة';

  @override
  String get methodTehran => 'طهران';

  @override
  String get methodTurkiye => 'تركيا (ديانت)';

  @override
  String get methodMoonsightingCommittee => 'لجنة رؤية الهلال';

  @override
  String get methodNorthAmerica => 'أمريكا الشمالية';

  @override
  String get methodOther => 'أخرى (افتراضي)';

  @override
  String get madhabShafi => 'الشافعي (قياسي)';

  @override
  String get madhabHanafi => 'الحنفي';

  @override
  String get soundModeFull => 'الأذان كاملاً';

  @override
  String get soundModeShort => 'صوت قصير';

  @override
  String get soundModeSilent => 'صامت (اهتزاز)';

  @override
  String get soundModeFullCompact => 'كامل';

  @override
  String get soundModeShortCompact => 'قصير';

  @override
  String get soundModeSilentCompact => 'صامت';

  @override
  String get statusPrayed => 'صليت';

  @override
  String get statusLate => 'صليت متأخرًا';

  @override
  String get statusMissed => 'فاتتني';

  @override
  String notificationPrayerTimeTitle(String prayer) {
    return 'وقت صلاة $prayer';
  }

  @override
  String notificationPrayerTimeBodySilent(String prayer) {
    return 'حان وقت صلاة $prayer.';
  }

  @override
  String notificationPrayerTimeBody(String prayer, String reciter) {
    return 'حان وقت صلاة $prayer — $reciter';
  }

  @override
  String get notificationTestTitle => 'إشعار تجريبي';

  @override
  String get notificationTestBodySilent => 'هذا شكل إشعار الصلاة الصامت.';

  @override
  String notificationTestBody(String mode) {
    return 'هذا صوت إشعار صلاة $mode.';
  }
}
