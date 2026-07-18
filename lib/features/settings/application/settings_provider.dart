import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/adhan_sound_mode.dart';
import '../../../core/models/calculation_settings.dart';
import '../../../core/services/prayer_time_service.dart';

class PrayerSettings {
  const PrayerSettings({
    required this.method,
    required this.madhab,
    required this.adjustments,
    required this.soundModes,
    required this.reciterId,
    required this.overrideSilentMode,
    required this.azkarEnabled,
    required this.azkarCount,
    required this.showAyahOnOpen,
    required this.fridayKahfReminderEnabled,
    required this.userName,
  });

  final PrayerCalculationMethod method;
  final PrayerMadhab madhab;

  /// Manual +/- minute nudge per prayer, applied on top of the calculated
  /// time until the user changes it again (persists across days).
  final Map<DailyPrayer, int> adjustments;

  /// Full Adhan / short sound / silent, per prayer.
  final Map<DailyPrayer, AdhanSoundMode> soundModes;

  final String reciterId;

  /// Whether the full-Adhan sound should play even when the device is in
  /// silent/vibrate mode (like an alarm clock does). Off by default —
  /// the settings screen asks for explicit confirmation before enabling.
  final bool overrideSilentMode;

  /// Whether to send occasional azkar (dhikr) reminders at random times
  /// through the day.
  final bool azkarEnabled;

  /// How many azkar reminders to send per day when enabled.
  final int azkarCount;

  /// Whether to show a random Quranic ayah popup each time the app opens.
  final bool showAyahOnOpen;

  /// Whether to send a Friday reminder to read Surah Al-Kahf.
  final bool fridayKahfReminderEnabled;

  /// The user's display name, used for the home screen greeting. Empty if
  /// not set.
  final String userName;

  Reciter get reciter => availableReciters.firstWhere(
        (r) => r.id == reciterId,
        orElse: () => defaultReciter,
      );

  PrayerSettings copyWith({
    PrayerCalculationMethod? method,
    PrayerMadhab? madhab,
    Map<DailyPrayer, int>? adjustments,
    Map<DailyPrayer, AdhanSoundMode>? soundModes,
    String? reciterId,
    bool? overrideSilentMode,
    bool? azkarEnabled,
    int? azkarCount,
    bool? showAyahOnOpen,
    bool? fridayKahfReminderEnabled,
    String? userName,
  }) =>
      PrayerSettings(
        method: method ?? this.method,
        madhab: madhab ?? this.madhab,
        adjustments: adjustments ?? this.adjustments,
        soundModes: soundModes ?? this.soundModes,
        reciterId: reciterId ?? this.reciterId,
        overrideSilentMode: overrideSilentMode ?? this.overrideSilentMode,
        azkarEnabled: azkarEnabled ?? this.azkarEnabled,
        azkarCount: azkarCount ?? this.azkarCount,
        showAyahOnOpen: showAyahOnOpen ?? this.showAyahOnOpen,
        fridayKahfReminderEnabled: fridayKahfReminderEnabled ?? this.fridayKahfReminderEnabled,
        userName: userName ?? this.userName,
      );
}

class PrayerSettingsNotifier extends StateNotifier<PrayerSettings> {
  PrayerSettingsNotifier()
      : super(PrayerSettings(
          method: PrayerCalculationMethod.egyptian,
          madhab: PrayerMadhab.shafi,
          adjustments: {for (final p in DailyPrayer.values) p: 0},
          soundModes: {for (final p in DailyPrayer.values) p: AdhanSoundMode.full},
          reciterId: defaultReciter.id,
          overrideSilentMode: false,
          azkarEnabled: true,
          azkarCount: 5,
          showAyahOnOpen: true,
          fridayKahfReminderEnabled: true,
          userName: '',
        )) {
    _load();
  }

  static const _methodKey = 'calculation_method';
  static const _madhabKey = 'madhab';
  static const _reciterKey = 'reciter_id';
  static const _overrideSilentKey = 'override_silent_mode';
  static const _azkarEnabledKey = 'azkar_enabled';
  static const _azkarCountKey = 'azkar_count';
  static const _showAyahOnOpenKey = 'show_ayah_on_open';
  static const _fridayKahfReminderKey = 'friday_kahf_reminder_enabled';
  static const _userNameKey = 'user_name';
  static String _adjustmentKey(DailyPrayer prayer) => 'adjustment_${prayer.name}';
  static String _soundModeKey(DailyPrayer prayer) => 'sound_mode_${prayer.name}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final methodName = prefs.getString(_methodKey);
    final madhabName = prefs.getString(_madhabKey);

    final method = PrayerCalculationMethod.values
        .where((m) => m.name == methodName)
        .cast<PrayerCalculationMethod?>()
        .firstOrNull;
    final madhab = PrayerMadhab.values
        .where((m) => m.name == madhabName)
        .cast<PrayerMadhab?>()
        .firstOrNull;

    final adjustments = {
      for (final p in DailyPrayer.values) p: prefs.getInt(_adjustmentKey(p)) ?? 0,
    };

    final soundModes = {
      for (final p in DailyPrayer.values)
        p: AdhanSoundMode.values
            .where((m) => m.name == prefs.getString(_soundModeKey(p)))
            .cast<AdhanSoundMode?>()
            .firstOrNull ??
            AdhanSoundMode.full,
    };

    state = state.copyWith(
      method: method,
      madhab: madhab,
      adjustments: adjustments,
      soundModes: soundModes,
      reciterId: prefs.getString(_reciterKey),
      overrideSilentMode: prefs.getBool(_overrideSilentKey) ?? false,
      azkarEnabled: prefs.getBool(_azkarEnabledKey) ?? true,
      azkarCount: prefs.getInt(_azkarCountKey) ?? 5,
      showAyahOnOpen: prefs.getBool(_showAyahOnOpenKey) ?? true,
      fridayKahfReminderEnabled: prefs.getBool(_fridayKahfReminderKey) ?? true,
      userName: prefs.getString(_userNameKey) ?? '',
    );
  }

  Future<void> setMethod(PrayerCalculationMethod method) async {
    state = state.copyWith(method: method);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_methodKey, method.name);
  }

  Future<void> setMadhab(PrayerMadhab madhab) async {
    state = state.copyWith(madhab: madhab);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_madhabKey, madhab.name);
  }

  Future<void> setAdjustment(DailyPrayer prayer, int minutes) async {
    final updated = Map<DailyPrayer, int>.from(state.adjustments)..[prayer] = minutes;
    state = state.copyWith(adjustments: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_adjustmentKey(prayer), minutes);
  }

  Future<void> setSoundMode(DailyPrayer prayer, AdhanSoundMode mode) async {
    final updated = Map<DailyPrayer, AdhanSoundMode>.from(state.soundModes)..[prayer] = mode;
    state = state.copyWith(soundModes: updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundModeKey(prayer), mode.name);
  }

  Future<void> setReciter(String reciterId) async {
    state = state.copyWith(reciterId: reciterId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterId);
  }

  Future<void> setOverrideSilentMode(bool value) async {
    state = state.copyWith(overrideSilentMode: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overrideSilentKey, value);
  }

  Future<void> setAzkarEnabled(bool value) async {
    state = state.copyWith(azkarEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_azkarEnabledKey, value);
  }

  Future<void> setAzkarCount(int count) async {
    state = state.copyWith(azkarCount: count);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_azkarCountKey, count);
  }

  Future<void> setShowAyahOnOpen(bool value) async {
    state = state.copyWith(showAyahOnOpen: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showAyahOnOpenKey, value);
  }

  Future<void> setFridayKahfReminderEnabled(bool value) async {
    state = state.copyWith(fridayKahfReminderEnabled: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fridayKahfReminderKey, value);
  }

  Future<void> setUserName(String name) async {
    state = state.copyWith(userName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }
}

final prayerSettingsProvider = StateNotifierProvider<PrayerSettingsNotifier, PrayerSettings>(
  (ref) => PrayerSettingsNotifier(),
);
