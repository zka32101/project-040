import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 音声効果の管理サービス。
/// 正解・不正解・バイク解放などのSEを再生。
abstract class SoundEffectsService {
  /// SE有効化（ミュート状態）を取得
  bool get isMuted;

  /// SE有効化を設定
  Future<void> setMuted(bool value);

  /// 正解音を再生
  Future<void> playCorrectionSound();

  /// 不正解音を再生
  Future<void> playIncorrectSound();

  /// バイク解放音を再生
  Future<void> playBikeUnlockSound();
}

/// just_audio を使った実装
class LocalSoundEffectsService implements SoundEffectsService {
  LocalSoundEffectsService();

  static const _muteKey = 'sound_effects_muted';

  bool _isMuted = false;

  final Map<String, AudioPlayer> _players = {
    'correction': AudioPlayer(),
    'incorrect': AudioPlayer(),
    'bikeUnlock': AudioPlayer(),
  };

  /// 初期化：SharedPreferences からミュート状態を復元
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMuted = prefs.getBool(_muteKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load sound preferences: $e');
      }
    }
  }

  @override
  bool get isMuted => _isMuted;

  @override
  Future<void> setMuted(bool value) async {
    _isMuted = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_muteKey, value);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save sound preferences: $e');
      }
    }
  }

  @override
  Future<void> playCorrectionSound() async {
    if (_isMuted) return;
    await _playSound('correction', 'assets/sounds/correct.mp3');
  }

  @override
  Future<void> playIncorrectSound() async {
    if (_isMuted) return;
    await _playSound('incorrect', 'assets/sounds/incorrect.mp3');
  }

  @override
  Future<void> playBikeUnlockSound() async {
    if (_isMuted) return;
    await _playSound('bikeUnlock', 'assets/sounds/bike_unlock.mp3');
  }

  Future<void> _playSound(String key, String assetPath) async {
    try {
      final player = _players[key];
      if (player == null) return;

      // 前の再生を停止
      await player.stop();

      // アセットから音声を読み込んで再生
      // アセットが存在しない場合はハプティクスフィードバックにフォールバック
      try {
        await player.setAsset(assetPath);
        await player.play();
      } on FileSystemException {
        // アセットが存在しない場合：開発中の工数削減のためハプティクスで代替
        _playHapticFeedback(key);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play sound $key: $e');
      }
    }
  }

  void _playHapticFeedback(String soundType) {
    try {
      switch (soundType) {
        case 'correction':
          HapticFeedback.mediumImpact();
        case 'incorrect':
          HapticFeedback.lightImpact();
        case 'bikeUnlock':
          HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to play haptic feedback: $e');
      }
    }
  }

  /// リソース解放
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
  }
}

/// テスト用スタブ実装
class StubSoundEffectsService implements SoundEffectsService {
  bool _isMuted = false;

  @override
  bool get isMuted => _isMuted;

  @override
  Future<void> setMuted(bool value) async => _isMuted = value;

  @override
  Future<void> playCorrectionSound() async {
    if (kDebugMode) print('Playing correction sound');
  }

  @override
  Future<void> playIncorrectSound() async {
    if (kDebugMode) print('Playing incorrect sound');
  }

  @override
  Future<void> playBikeUnlockSound() async {
    if (kDebugMode) print('Playing bike unlock sound');
  }
}
