import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryService {
  DiaryService._();

  static final DiaryService instance = DiaryService._();

  String? get _userId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  String get _storageKey {
    final userId = _userId;

    if (userId == null) {
      return "inkly_diaries_guest";
    }

    return "inkly_diaries_$userId";
  }

  // ---------------------------------------------------------
  // GET ALL DIARIES
  // ---------------------------------------------------------

  Future<List<Map<String, dynamic>>> getDiaries() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(_storageKey) ?? [];

    return data.map((item) {
      return Map<String, dynamic>.from(jsonDecode(item));
    }).toList();
  }

  // ---------------------------------------------------------
  // SAVE / UPDATE DIARY
  // ---------------------------------------------------------

  Future<void> saveDiary({
    required String id,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final diaries = await getDiaries();

    // Find existing diary
    final index = diaries.indexWhere((item) => item["id"] == id);

    // Preserve existing favorite status
    bool favorite = false;

    if (index >= 0) {
      favorite =
          diaries[index]["isFavorite"] == true ||
          diaries[index]["favorite"] == true;
    }

    // If a new favorite value is provided, use it
    if (isFavorite != null) {
      favorite = isFavorite;
    }

    final diary = <String, dynamic>{
      "id": id,
      "title": title,
      "content": content,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": (updatedAt ?? DateTime.now()).toIso8601String(),
      "isFavorite": favorite,
    };

    if (index >= 0) {
      diaries[index] = diary;
    } else {
      diaries.insert(0, diary);
    }

    final encoded = diaries.map((item) => jsonEncode(item)).toList();

    await prefs.setStringList(_storageKey, encoded);

    print("✅ Diary auto-saved");
    print("📝 ID: $id");
    print("📝 Title: $title");
    print("📅 Diary date: $createdAt");
    print("❤️ Favorite: $favorite");
  }

  // ---------------------------------------------------------
  // TOGGLE FAVORITE
  // ---------------------------------------------------------

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final diaries = await getDiaries();

    final index = diaries.indexWhere((item) => item["id"] == id);

    if (index == -1) {
      print("❌ Diary not found: $id");
      return;
    }

    final currentFavorite =
        diaries[index]["isFavorite"] == true ||
        diaries[index]["favorite"] == true;

    diaries[index]["isFavorite"] = !currentFavorite;

    final encoded = diaries.map((item) => jsonEncode(item)).toList();

    await prefs.setStringList(_storageKey, encoded);

    if (!currentFavorite) {
      print("❤️ Diary marked as favorite");
    } else {
      print("🤍 Diary removed from favorites");
    }
  }

  // ---------------------------------------------------------
  // GET ONE DIARY
  // ---------------------------------------------------------

  Future<Map<String, dynamic>?> getDiary(String id) async {
    final diaries = await getDiaries();

    try {
      return diaries.firstWhere((item) => item["id"] == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------
  // DELETE DIARY
  // ---------------------------------------------------------

  Future<void> deleteDiary(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final diaries = await getDiaries();

    diaries.removeWhere((item) => item["id"] == id);

    final encoded = diaries.map((item) => jsonEncode(item)).toList();

    await prefs.setStringList(_storageKey, encoded);

    print("🗑️ Diary deleted: $id");
  }
}
