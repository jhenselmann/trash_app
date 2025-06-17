import 'package:shared_preferences/shared_preferences.dart';

class SavedTrashcanService {
  static const _key = 'saved_trashcan_ids';

  static Future<Set<String>> _getSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  /// Gibt die gespeicherten Trashcan-IDs als Liste zurück
  static Future<List<String>> getSavedTrashcanIds() async {
    final saved = await _getSavedIds();
    return saved.toList();
  }

  static Future<bool> isSaved(String id) async {
    final saved = await _getSavedIds();
    return saved.contains(id);
  }

  static Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await _getSavedIds();

    if (saved.contains(id)) {
      saved.remove(id);
    } else {
      saved.add(id);
    }

    await prefs.setStringList(_key, saved.toList());
  }
}
