import 'package:adhan_dart/adhan_dart.dart';

import '../../l10n/generated/app_localizations.dart';

/// User-facing prayer time calculation methods, mapped to the
/// underlying adhan_dart [CalculationParameters] presets.
enum PrayerCalculationMethod {
  muslimWorldLeague,
  egyptian,
  ummAlQura,
  isna,
  karachi,
  dubai,
  kuwait,
  qatar,
  singapore,
  tehran,
  turkiye,
  moonsightingCommittee,
  northAmerica,
  other;

  String label(AppLocalizations l10n) {
    switch (this) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return l10n.methodMuslimWorldLeague;
      case PrayerCalculationMethod.egyptian:
        return l10n.methodEgyptian;
      case PrayerCalculationMethod.ummAlQura:
        return l10n.methodUmmAlQura;
      case PrayerCalculationMethod.isna:
        return l10n.methodIsna;
      case PrayerCalculationMethod.karachi:
        return l10n.methodKarachi;
      case PrayerCalculationMethod.dubai:
        return l10n.methodDubai;
      case PrayerCalculationMethod.kuwait:
        return l10n.methodKuwait;
      case PrayerCalculationMethod.qatar:
        return l10n.methodQatar;
      case PrayerCalculationMethod.singapore:
        return l10n.methodSingapore;
      case PrayerCalculationMethod.tehran:
        return l10n.methodTehran;
      case PrayerCalculationMethod.turkiye:
        return l10n.methodTurkiye;
      case PrayerCalculationMethod.moonsightingCommittee:
        return l10n.methodMoonsightingCommittee;
      case PrayerCalculationMethod.northAmerica:
        return l10n.methodNorthAmerica;
      case PrayerCalculationMethod.other:
        return l10n.methodOther;
    }
  }

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
  shafi,
  hanafi;

  String label(AppLocalizations l10n) => this == PrayerMadhab.shafi ? l10n.madhabShafi : l10n.madhabHanafi;

  Madhab toMadhab() => this == PrayerMadhab.shafi ? Madhab.shafi : Madhab.hanafi;
}
