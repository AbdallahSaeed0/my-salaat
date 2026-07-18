import 'package:audioplayers/audioplayers.dart';

import '../models/adhan_sound_mode.dart';

/// Foreground playback for previewing a reciter in Settings, or playing the
/// Adhan while the app is open (e.g. the home screen's live countdown
/// reaching zero). Background/closed-app playback at the scheduled prayer
/// time is handled separately by the OS via the notification channel's
/// sound (see NotificationService) — this service only covers in-app use.
class AdhanAudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Fires when playback finishes on its own (as opposed to being stopped),
  /// so UI can reset a playing/stop toggle back to its idle state.
  Stream<void> get onComplete => _player.onPlayerComplete;

  Future<void> playAsset(String assetPath) async {
    final relativePath = assetPath.startsWith('assets/') ? assetPath.substring('assets/'.length) : assetPath;
    await _player.stop();
    await _player.play(AssetSource(relativePath));
  }

  Future<void> playReciter(Reciter reciter) => playAsset(reciter.assetPath);

  Future<void> playShortSound() => playAsset(shortSoundAssetPath);

  Future<void> stop() => _player.stop();

  void dispose() => _player.dispose();
}
