import 'package:audioplayers/audioplayers.dart';

// মিশারী রাশিদ আল-আফাসীর তিলাওয়াত (everyayah.com CDN)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  int? _playingSurah;
  int? _playingAyah; // 0-based index
  bool _playingAll = false;
  int _totalAyahs = 0;
  Function(int?)? onAyahChanged;

  int? get playingAyah => _playingAyah;
  bool get isPlayingAll => _playingAll;

  static String ayahUrl(int surahId, int ayahIdx) {
    final s = surahId.toString().padLeft(3, '0');
    final a = (ayahIdx + 1).toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
  }

  void _setupListener() {
    _player.onPlayerComplete.listen((_) {
      if (_playingAll &&
          _playingSurah != null &&
          _playingAyah != null) {
        final next = _playingAyah! + 1;
        if (next < _totalAyahs) {
          playAyah(_playingSurah!, next, _totalAyahs,
              playAll: true);
        } else {
          stop();
        }
      } else {
        _playingAyah = null;
        onAyahChanged?.call(null);
      }
    });
  }

  bool _listenerSetup = false;

  Future<void> playAyah(int surahId, int ayahIdx,
      int totalAyahs, {bool playAll = false}) async {
    if (!_listenerSetup) {
      _setupListener();
      _listenerSetup = true;
    }
    _playingSurah = surahId;
    _playingAyah = ayahIdx;
    _totalAyahs = totalAyahs;
    _playingAll = playAll;
    onAyahChanged?.call(ayahIdx);
    try {
      await _player.stop();
      await _player
          .play(UrlSource(ayahUrl(surahId, ayahIdx)));
    } catch (_) {
      _playingAyah = null;
      onAyahChanged?.call(null);
    }
  }

  Future<void> playAll(int surahId, int totalAyahs) async {
    await playAyah(surahId, 0, totalAyahs, playAll: true);
  }

  Future<void> stop() async {
    _playingAll = false;
    _playingAyah = null;
    _playingSurah = null;
    await _player.stop();
    onAyahChanged?.call(null);
  }

  Future<void> toggleAyah(
      int surahId, int ayahIdx, int totalAyahs) async {
    if (_playingAyah == ayahIdx &&
        _playingSurah == surahId) {
      await stop();
    } else {
      // ওই আয়াত থেকে শুরু করে সূরার শেষ পর্যন্ত বাজবে
      await playAyah(surahId, ayahIdx, totalAyahs,
          playAll: true);
    }
  }

  void dispose() {
    _player.dispose();
  }
}
