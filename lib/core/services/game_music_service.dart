import 'dart:math';

import 'package:flame_audio/flame_audio.dart';

enum GameMusicMood { calm, playful, energetic }

class GameMusicService {
  GameMusicService._();

  static final GameMusicService instance = GameMusicService._();

  final Random _random = Random();

  String? _lastTrack;
  bool _initialized = false;

  static const List<String> _calmTracks = [
    'music/ambient_track.mp3',
    'music/cozy_puzzle_title.mp3',
    'music/jazz_n_brass_loop.mp3',
    'music/vision_loop_03.mp3',
  ];

  static const List<String> _playfulTracks = [
    'music/overworld_theme.mp3',
    'music/joyful_jungle.mp3',
    'music/funky_menu_loop.mp3',
    'music/vision_loop_01.mp3',
    'music/vision_loop_02.mp3',
  ];

  static const List<String> _energeticTracks = [
    'music/fever_stadium.mp3',
    'music/super_wreck_roadway.mp3',
    'music/space_city.mp3',
    'music/hope_orchestral_battle.mp3',
    'music/vision_loop_02.mp3',
  ];

  void _initialize() {
    if (_initialized) return;

    FlameAudio.bgm.initialize();

    _initialized = true;
  }

  Future<void> playRandom({
    required Set<GameMusicMood> moods,
    double volume = 0.24,
  }) async {
    _initialize();

    final tracks = <String>{};

    for (final mood in moods) {
      switch (mood) {
        case GameMusicMood.calm:
          tracks.addAll(_calmTracks);

        case GameMusicMood.playful:
          tracks.addAll(_playfulTracks);

        case GameMusicMood.energetic:
          tracks.addAll(_energeticTracks);
      }
    }

    if (tracks.isEmpty) return;

    var candidates = tracks.toList();

    if (candidates.length > 1 && _lastTrack != null) {
      candidates = candidates.where((track) => track != _lastTrack).toList();
    }

    final selectedTrack = candidates[_random.nextInt(candidates.length)];

    await FlameAudio.audioCache.load(selectedTrack);

    await FlameAudio.bgm.stop();

    await FlameAudio.bgm.play(selectedTrack, volume: volume);

    _lastTrack = selectedTrack;
  }

  Future<void> stop() async {
    if (!_initialized) return;

    await FlameAudio.bgm.stop();
  }
}
