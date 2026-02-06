import 'package:flutter/material.dart';

/// Model class representing an academic session.
/// A session can be a Class, Mastery Session, Study Group, or PSL Meeting.
class Session {
  // Unique identifier for the session
  String id;

  // Title of the session (e.g., "Mobile App Development")
  String title;

  // The date the session takes place
  DateTime date;

  // When the session starts
  TimeOfDay startTime;

  // When the session ends
  TimeOfDay endTime;

  // Optional location (e.g., "Room 301", "Online")
  String? location;

  // Type of session: Class, Mastery Session, Study Group, PSL Meeting
  String type;

  // Whether the student attended this session
  bool isPresent;

  // Whether attendance has been marked for this session
  bool attendanceRecorded;

  /// Constructor — only title, date, times, and type are required
  Session({
    String? id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.type,
    this.isPresent = false,
    this.attendanceRecorded = false,
  }) : id = id ?? UniqueKey().toString();

  // ----- Formatting helpers -----

  /// Returns date as "Mon, Jan 15, 2026"
  String get formattedDate {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  /// Formats a TimeOfDay into "9:00 AM" style
  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Returns "9:00 AM - 11:00 AM"
  String get formattedTimeRange =>
      '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  /// Duration of the session in minutes
  int get durationMinutes {
    return (endTime.hour * 60 + endTime.minute) -
        (startTime.hour * 60 + startTime.minute);
  }

  /// Whether this session is scheduled for today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Whether this session falls within the given week (Mon-Sun)
  bool isInWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final sessionDate = DateTime(date.year, date.month, date.day);
    return !sessionDate.isBefore(weekStart) && sessionDate.isBefore(weekEnd);
  }

  /// Creates a copy with optional field overrides
  Session copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? type,
    bool? isPresent,
    bool? attendanceRecorded,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      type: type ?? this.type,
      isPresent: isPresent ?? this.isPresent,
      attendanceRecorded: attendanceRecorded ?? this.attendanceRecorded,
    );
  }

  @override
  String toString() =>
      'Session($title, $formattedDate, $formattedTimeRange, $type)';
}

// ----- Session type helpers -----

/// Contains constants and helpers for the four session types
class SessionTypes {
  static const String classSession = 'Class';
  static const String masterySession = 'Mastery Session';
  static const String studyGroup = 'Study Group';
  static const String pslMeeting = 'PSL Meeting';

  /// All available session types
  static const List<String> all = [
    classSession,
    masterySession,
    studyGroup,
    pslMeeting,
  ];

  /// Returns a color for each session type (used in UI badges)
  static Color getColor(String sessionType) {
    switch (sessionType) {
      case classSession:
        return const Color(0xFF0056A0); // ALU primary blue
      case masterySession:
        return const Color(0xFF7C3AED); // Purple
      case studyGroup:
        return const Color(0xFF059669); // Green
      case pslMeeting:
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon for each session type
  static IconData getIcon(String sessionType) {
    switch (sessionType) {
      case classSession:
        return Icons.school;
      case masterySession:
        return Icons.lightbulb;
      case studyGroup:
        return Icons.groups;
      case pslMeeting:
        return Icons.meeting_room;
      default:
        return Icons.event;
    }
  }
}
