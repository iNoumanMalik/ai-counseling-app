import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for local storage operations
class StorageService {
  static const String _keyUserName = 'user_name';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyMoodHistory = 'mood_history';
  static const String _keyJournalEntries = 'journal_entries';
  static const String _keyHabits = 'habits';
  static const String _keyHabitStreak = 'habit_streak';
  static const String _keyBadges = 'badges';
  static const String _keySavedCounselors = 'saved_counselors';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyCheckins = 'checkins';
  static const String _keyHabitLog = 'habit_log';
  static const String _keyHabitDefs = 'habit_defs';
  static const String _keyHabitsLastReset = 'habits_last_reset';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // User name
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserName);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserName, name);
  }

  // User avatar
  static Future<String?> getUserAvatar() async {
    final prefs = await _prefs;
    return prefs.getString(_keyUserAvatar);
  }

  static Future<void> setUserAvatar(String avatar) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserAvatar, avatar);
  }

  // Onboarding
  static Future<bool> isOnboardingComplete() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboardingComplete, complete);
  }

  // Mood history
  static Future<List<Map<String, dynamic>>> getMoodHistory() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyMoodHistory);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addMoodEntry(Map<String, dynamic> moodEntry) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> history = await getMoodHistory();
    history.add(moodEntry);
    await prefs.setString(_keyMoodHistory, jsonEncode(history));
  }

  // Journal entries
  static Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyJournalEntries);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveJournalEntry(Map<String, dynamic> entry) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> entries = await getJournalEntries();
    entries.add(entry);
    await prefs.setString(_keyJournalEntries, jsonEncode(entries));
  }

  static Future<void> deleteJournalEntry(String id) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> entries = await getJournalEntries();
    entries.removeWhere((entry) => entry['id'] == id);
    await prefs.setString(_keyJournalEntries, jsonEncode(entries));
  }

  // Habits
  static Future<Map<String, dynamic>> getHabits() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyHabits);
    if (json == null) return {};
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  static Future<void> updateHabit(String habitId, bool completed) async {
    final prefs = await _prefs;
    final Map<String, dynamic> habits = await getHabits();
    habits[habitId] = {
      'completed': completed,
      'date': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_keyHabits, jsonEncode(habits));
  }

  static Future<List<Map<String, dynamic>>> getHabitDefs() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyHabitDefs);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHabitDef(Map<String, dynamic> def) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> defs = await getHabitDefs();
    defs.removeWhere((d) => d['id'] == def['id']);
    defs.add(def);
    await prefs.setString(_keyHabitDefs, jsonEncode(defs));
  }

  static Future<void> deleteHabitDef(String id) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> defs = await getHabitDefs();
    defs.removeWhere((d) => d['id'] == id);
    await prefs.setString(_keyHabitDefs, jsonEncode(defs));
  }

  static Future<String?> getHabitsLastReset() async {
    final prefs = await _prefs;
    return prefs.getString(_keyHabitsLastReset);
  }

  static Future<void> setHabitsLastReset(String isoDate) async {
    final prefs = await _prefs;
    await prefs.setString(_keyHabitsLastReset, isoDate);
  }

  // Streaks
  static Future<int> getHabitStreak() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyHabitStreak) ?? 0;
  }

  static Future<void> setHabitStreak(int streak) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyHabitStreak, streak);
  }

  // Badges
  static Future<List<String>> getBadges() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyBadges);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addBadge(String badgeId) async {
    final prefs = await _prefs;
    final List<String> badges = await getBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await prefs.setString(_keyBadges, jsonEncode(badges));
    }
  }

  // Saved counselors
  static Future<List<Map<String, dynamic>>> getSavedCounselors() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keySavedCounselors);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCounselor(Map<String, dynamic> counselor) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> saved = await getSavedCounselors();
    if (!saved.any((c) => c['id'] == counselor['id'])) {
      saved.add(counselor);
      await prefs.setString(_keySavedCounselors, jsonEncode(saved));
    }
  }

  // Notifications
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  static Future<List<Map<String, dynamic>>> getCheckins() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyCheckins);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCheckinEntry(Map<String, dynamic> entry) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> items = await getCheckins();
    items.add(entry);
    await prefs.setString(_keyCheckins, jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> getHabitLog() async {
    final prefs = await _prefs;
    final String? json = prefs.getString(_keyHabitLog);
    if (json == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addHabitLogEntry({required String habitId, required String date}) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> items = await getHabitLog();
    items.add({'habitId': habitId, 'date': date});
    await prefs.setString(_keyHabitLog, jsonEncode(items));
  }
}

