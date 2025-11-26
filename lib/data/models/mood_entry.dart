import 'package:intl/intl.dart';

/// Model for mood tracking entries
class MoodEntry {
  final String id;
  final String mood;
  final DateTime date;
  final String? note;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: json['mood'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(date);
  }
}

