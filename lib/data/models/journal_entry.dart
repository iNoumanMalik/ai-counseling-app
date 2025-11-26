import 'package:intl/intl.dart';

/// Model for journal entries
class JournalEntry {
  final String id;
  final String content;
  final DateTime date;
  final String? title;

  JournalEntry({
    required this.id,
    required this.content,
    required this.date,
    this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String get formattedTime {
    return DateFormat('hh:mm a').format(date);
  }

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }
}

