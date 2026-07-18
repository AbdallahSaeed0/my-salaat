import 'package:adhan_dart/adhan_dart.dart';

/// User-facing prayer time calculation methods, mapped to the
/// underlying adhan_dart [CalculationParameters] presets.
enum PrayerCalculationMethod {
  muslimWorldLeague('Muslim World League'),
  egyptian('Egyptian General Authority'),
  ummAlQura('Umm al-Qura'),
  isna('Islamic Society of North America (ISNA)'),
  karachi('University of Islamic Sciences, Karachi'),
  dubai('Dubai'),
  kuwait('Kuwait'),
  qatar('Qatar'),
  singapore('Singapore'),
  tehran('Tehran'),
  turkiye('Turkiye (Diyanet)'),
  moonsightingCommittee('Moonsighting Committee'),
  northAmerica('North America'),
  other('Other (default)');

  const PrayerCalculationMethod(this.label);

  final String label;

  CalculationParameters toParameters() {
    switch (this) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return CalculationMethodParameters.muslimWorldLeague();
      case PrayerCalculationMethod.egyptian:
        return CalculationMethodParameters.egyptian();
      case PrayerCalculationMethod.ummAlQura:
        return CalculationMethodParameters.ummAlQura();
      case PrayerCalculationMethod.isna:
        return CalculationMethodParameters.northAmerica();
      case PrayerCalculationMethod.karachi:
        return CalculationMethodParameters.karachi();
      case PrayerCalculationMethod.dubai:
        return CalculationMethodParameters.dubai();
      case PrayerCalculationMethod.kuwait:
        return CalculationMethodParameters.kuwait();
      case PrayerCalculationMethod.qatar:
        return CalculationMethodParameters.qatar();
      case PrayerCalculationMethod.singapore:
        return CalculationMethodParameters.singapore();
      case PrayerCalculationMethod.tehran:
        return CalculationMethodParameters.tehran();
      case PrayerCalculationMethod.turkiye:
        return CalculationMethodParameters.turkiye();
      case PrayerCalculationMethod.moonsightingCommittee:
        return CalculationMethodParameters.moonsightingCommittee();
      case PrayerCalculationMethod.northAmerica:
        return CalculationMethodParameters.northAmerica();
      case PrayerCalculationMethod.other:
        return CalculationMethodParameters.other();
    }
  }
}

enum PrayerMadhab {
  shafi('Shafi (standard)'),
  hanafi('Hanafi');

  const PrayerMadhab(this.label);

  final String label;

  Madhab toMadhab() => this == PrayerMadhab.shafi ? Madhab.shafi : Madhab.hanafi;
}
