import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/trashcan.dart';

class UserTrashcanService {
  static const _key = 'user_added_trashcans';

  static Future<List<Trashcan>> loadUserTrashcans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((jsonStr) => Trashcan.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  static Future<void> addUserTrashcan(Trashcan trashcan) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.add(jsonEncode(trashcan.toJson()));
    await prefs.setStringList(_key, current);
  }

  static Future<void> deleteUserTrashcan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final updated =
        raw.where((e) {
          final map = json.decode(e) as Map<String, dynamic>;
          return map['id'] != id;
        }).toList();

    await prefs.setStringList(_key, updated);
  }
}
