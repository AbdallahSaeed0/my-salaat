/// How a prayer notification should sound when it fires.
enum AdhanSoundMode {
  /// Plays the full Adhan recording.
  full('Full Adhan'),

  /// Plays a short notification chime instead of the full recording.
  short('Short Sound'),

  /// No sound — vibration only (subject to device vibration settings).
  silent('Silent (Vibrate)');

  const AdhanSoundMode(this.label);

  final String label;
}

/// A selectable reciter for the full-Adhan sound.
class Reciter {
  const Reciter({required this.id, required this.name, required this.assetPath, required this.androidRawResource});

  final String id;
  final String name;

  /// Path under the Flutter asset bundle, for in-app preview playback.
  final String assetPath;

  /// Resource name (no extension) under android/app/src/main/res/raw, for
  /// the notification channel's sound.
  final String androidRawResource;
}

/// "Beautiful adhan.ogg" — CC0 (public domain) recording from Wikimedia
/// Commons: https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg
/// No attribution required, but credited here for provenance. (2:34)
const defaultReciter = Reciter(
  id: 'default',
  name: 'Adhan — Long',
  assetPath: 'assets/audio/adhan_placeholder.ogg',
  androidRawResource: 'adhan_placeholder',
);

/// "Call to prayer by Sabah Fakhry.mp3" — Public Domain (pre-1931
/// publication) recording from Wikimedia Commons:
/// https://commons.wikimedia.org/wiki/File:Call_to_prayer_by_Sabah_Fakhry.mp3
/// (2:38)
const sabahFakhryReciter = Reciter(
  id: 'sabah_fakhry',
  name: 'Adhan — Sabah Fakhry (Long)',
  assetPath: 'assets/audio/adhan_sabah_fakhry.mp3',
  androidRawResource: 'adhan_sabah_fakhry',
);

/// A ~15s trim of the opening Takbir from [defaultReciter]'s recording, for
/// a shorter full-Adhan option. Same CC0 source, just cut and faded out.
const shortReciter = Reciter(
  id: 'short',
  name: 'Adhan — Short',
  assetPath: 'assets/audio/adhan_short.ogg',
  androidRawResource: 'adhan_short',
);

const availableReciters = [defaultReciter, sabahFakhryReciter, shortReciter];

const shortSoundAssetPath = 'assets/audio/short_beep.wav';
const shortSoundAndroidRawResource = 'short_beep';
