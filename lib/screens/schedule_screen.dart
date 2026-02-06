import 'package:flutter/material.dart';
import '../models/session.dart';

// =============================================
// ALU BRANDING COLORS
// These match the official ALU color palette
// =============================================
const Color aluPrimary = Color(0xFF0056A0); // Dark blue
const Color aluAccent = Color(0xFF00AEEF); // Light blue
const Color aluWarning = Color(0xFFFF5E5E); // Red for warnings/alerts
const Color aluBackground = Color(0xFFF5F7FA); // Light background
const Color aluCardBg = Colors.white;
const Color aluTextDark = Color(0xFF1A1A2E);
const Color aluTextLight = Color(0xFF6B7280);

/// ScheduleScreen — Screen 3 of the ALU Academic App
///
/// This screen lets students:
///  - View their weekly academic schedule
///  - Add, edit, and delete sessions
///  - Record attendance (Present / Absent) for each session
///  - See a live attendance percentage summary
class ScheduleScreen extends StatefulWidget {
  /// The shared sessions list managed by the parent (HomeScreen in main.dart).
  /// This allows the Dashboard to also read the same sessions for attendance.
  final List<Session> sessions;

  /// Callback to notify the parent when sessions are added, edited, or deleted
  /// so the Dashboard can recalculate attendance percentage.
  final VoidCallback onSessionsChanged;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onSessionsChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // ------- STATE -------

  /// Reference to the shared sessions list from main.dart
  List<Session> get _sessions => widget.sessions;

  /// The Monday that starts the currently-viewed week
  late DateTime _currentWeekStart;

  /// Which day of the week is selected (0 = Mon … 6 = Sun)
  int _selectedDayIndex = 0;

  // ------- LIFECYCLE -------

  @override
  void initState() {
    super.initState();
    // Calculate the Monday of the current week
    final now = DateTime.now();
    _currentWeekStart = _getMondayOfWeek(now);
    // Pre-select today's weekday
    _selectedDayIndex = (now.weekday - 1).clamp(0, 6);
  }

  // ------- DATE HELPERS -------

  /// Returns the Monday 00:00 of the week that contains [date]
  DateTime _getMondayOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1; // Monday = 1 → 0
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Move to the previous week
  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  /// Move to the next week
  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  /// Jump back to the current week and select today
  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _currentWeekStart = _getMondayOfWeek(now);
      _selectedDayIndex = (now.weekday - 1).clamp(0, 6);
    });
  }

  /// Builds a DateTime for the selected day chip
  DateTime _getSelectedDate() {
    return _currentWeekStart.add(Duration(days: _selectedDayIndex));
  }

  // ------- SESSION FILTERING -------

  /// Returns sessions for the currently selected day, sorted by start time
  List<Session> _getSessionsForSelectedDay() {
    final selectedDate = _getSelectedDate();
    return _sessions.where((s) {
      return s.date.year == selectedDate.year &&
          s.date.month == selectedDate.month &&
          s.date.day == selectedDate.day;
    }).toList()..sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });
  }

  // ------- ATTENDANCE CALCULATION -------

  /// Overall attendance percentage across ALL sessions where attendance
  /// has been recorded
  double get _attendancePercentage {
    final recorded = _sessions.where((s) => s.attendanceRecorded).toList();
    if (recorded.isEmpty) return 100.0;
    final present = recorded.where((s) => s.isPresent).length;
    return (present / recorded.length) * 100;
  }

  /// Count of sessions marked as Present
  int get _presentCount =>
      _sessions.where((s) => s.attendanceRecorded && s.isPresent).length;

  /// Count of sessions marked as Absent
  int get _absentCount =>
      _sessions.where((s) => s.attendanceRecorded && !s.isPresent).length;

  // ------- ADD / EDIT SESSION -------

  /// Opens a bottom sheet form to create a new session or edit an existing one.
  ///
  /// When [existingSession] and [existingIndex] are provided, the form is
  /// pre-filled for editing.
  void _openSessionForm({Session? existingSession, int? existingIndex}) {
    // Controllers for text fields
    final titleCtrl = TextEditingController(text: existingSession?.title ?? '');
    final locationCtrl = TextEditingController(
      text: existingSession?.location ?? '',
    );

    // Form state variables — stored locally so the bottom sheet is
    // self-contained (uses StatefulBuilder for rebuilds)
    DateTime selectedDate = existingSession?.date ?? _getSelectedDate();
    TimeOfDay startTime =
        existingSession?.startTime ?? const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime =
        existingSession?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    String sessionType = existingSession?.type ?? SessionTypes.classSession;

    // Key for form validation
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---- Drag handle ----
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ---- Header ----
                      Text(
                        existingSession == null
                            ? 'Schedule New Session'
                            : 'Edit Session',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: aluPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---- Session Title (required) ----
                      TextFormField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: 'Session Title *',
                          hintText: 'e.g. Mobile App Development',
                          prefixIcon: const Icon(
                            Icons.title,
                            color: aluPrimary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: aluPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a session title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ---- Session Type Dropdown ----
                      DropdownButtonFormField<String>(
                        initialValue: sessionType,
                        decoration: InputDecoration(
                          labelText: 'Session Type',
                          prefixIcon: Icon(
                            SessionTypes.getIcon(sessionType),
                            color: SessionTypes.getColor(sessionType),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: aluPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                        items: SessionTypes.all.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Icon(
                                  SessionTypes.getIcon(type),
                                  size: 20,
                                  color: SessionTypes.getColor(type),
                                ),
                                const SizedBox(width: 8),
                                Text(type),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setModalState(() => sessionType = value!);
                        },
                      ),
                      const SizedBox(height: 14),

                      // ---- Location (optional) ----
                      TextFormField(
                        controller: locationCtrl,
                        decoration: InputDecoration(
                          labelText: 'Location (optional)',
                          hintText: 'e.g. Room 301',
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: aluPrimary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: aluPrimary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ---- Date Picker ----
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: aluPrimary,
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            prefixIcon: const Icon(
                              Icons.calendar_today,
                              color: aluPrimary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ---- Time Pickers (start & end side by side) ----
                      Row(
                        children: [
                          // Start time
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: startTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: aluPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setModalState(() => startTime = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  prefixIcon: const Icon(
                                    Icons.access_time,
                                    color: aluAccent,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  startTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // End time
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: endTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: aluPrimary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setModalState(() => endTime = picked);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Time',
                                  prefixIcon: const Icon(
                                    Icons.access_time,
                                    color: aluAccent,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  endTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ---- Time Validation Warning ----
                      Builder(
                        builder: (context) {
                          final startMin =
                              startTime.hour * 60 + startTime.minute;
                          final endMin = endTime.hour * 60 + endTime.minute;
                          if (endMin <= startMin) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: aluWarning,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'End time must be after start time',
                                    style: TextStyle(
                                      color: aluWarning,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // ---- Submit Button ----
                      ElevatedButton(
                        onPressed: () {
                          // Validate form fields
                          if (!formKey.currentState!.validate()) return;

                          // Validate that end time is after start time
                          final startMin =
                              startTime.hour * 60 + startTime.minute;
                          final endMin = endTime.hour * 60 + endTime.minute;
                          if (endMin <= startMin) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'End time must be after start time',
                                ),
                                backgroundColor: aluWarning,
                              ),
                            );
                            return;
                          }

                          // Build the new session object
                          final newSession = Session(
                            id: existingSession?.id,
                            title: titleCtrl.text.trim(),
                            date: selectedDate,
                            startTime: startTime,
                            endTime: endTime,
                            type: sessionType,
                            location: locationCtrl.text.trim().isEmpty
                                ? null
                                : locationCtrl.text.trim(),
                            isPresent: existingSession?.isPresent ?? false,
                            attendanceRecorded:
                                existingSession?.attendanceRecorded ?? false,
                          );

                          // Add or update the session in the master list
                          setState(() {
                            if (existingSession == null) {
                              _sessions.add(newSession);
                            } else {
                              _sessions[existingIndex!] = newSession;
                            }
                          });
                          // Notify parent so Dashboard updates attendance
                          widget.onSessionsChanged();

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                existingSession == null
                                    ? 'Session added successfully'
                                    : 'Session updated successfully',
                              ),
                              backgroundColor: aluPrimary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aluPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          existingSession == null
                              ? 'Add Session'
                              : 'Update Session',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ---- Cancel Button ----
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: aluTextLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ------- DELETE SESSION -------

  /// Shows a confirmation dialog and deletes the session at [index]
  void _deleteSession(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text(
          'Are you sure you want to remove "${_sessions[index].title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _sessions.removeAt(index));
              widget.onSessionsChanged();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session removed'),
                  backgroundColor: aluWarning,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: aluWarning)),
          ),
        ],
      ),
    );
  }

  // ------- TOGGLE ATTENDANCE -------

  /// Marks a session as Present or Absent
  void _toggleAttendance(int globalIndex, bool present) {
    setState(() {
      _sessions[globalIndex].isPresent = present;
      _sessions[globalIndex].attendanceRecorded = true;
    });
    // Notify parent so Dashboard recalculates attendance percentage
    widget.onSessionsChanged();
  }

  // ============================================
  // BUILD METHOD
  // ============================================

  @override
  Widget build(BuildContext context) {
    // Get sessions for the currently selected day
    final daySessions = _getSessionsForSelectedDay();

    return Scaffold(
      backgroundColor: aluBackground,

      // ---- App Bar ----
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: aluPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // "Today" quick-jump button
          TextButton(
            onPressed: _goToToday,
            child: const Text(
              'Today',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),

      // ---- FAB to add new session ----
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSessionForm(),
        backgroundColor: aluPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Session'),
      ),

      body: Column(
        children: [
          // ===== ATTENDANCE SUMMARY BAR =====
          _buildAttendanceSummary(),

          // ===== WEEK NAVIGATOR =====
          _buildWeekNavigator(),

          // ===== DAY SELECTOR CHIPS =====
          _buildDaySelector(),

          // ===== SESSION LIST =====
          Expanded(
            child: daySessions.isEmpty
                ? _buildEmptyState()
                : _buildSessionList(daySessions),
          ),
        ],
      ),
    );
  }

  // ============================================
  // UI BUILDING BLOCKS
  // ============================================

  /// Attendance summary bar at the top showing percentage + present/absent counts
  Widget _buildAttendanceSummary() {
    final percentage = _attendancePercentage;
    final isLow = percentage < 75;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: aluPrimary,
        boxShadow: [
          BoxShadow(
            color: aluPrimary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attendance percentage circle indicator
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLow
                  ? aluWarning.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: isLow ? aluWarning : Colors.white,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: isLow ? aluWarning : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Attendance label and counts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    // Warning icon when below 75%
                    if (isLow) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.warning_amber,
                        color: aluWarning,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Present: $_presentCount  |  Absent: $_absentCount  |  Total: ${_sessions.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Low attendance warning badge
          if (isLow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: aluWarning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'LOW',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Week navigation bar with left/right arrows and week date range label
  Widget _buildWeekNavigator() {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
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
    final label =
        '${months[_currentWeekStart.month - 1]} ${_currentWeekStart.day} – '
        '${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekEnd.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: aluPrimary),
            onPressed: _previousWeek,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: aluTextDark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: aluPrimary),
            onPressed: _nextWeek,
          ),
        ],
      ),
    );
  }

  /// Horizontal day-of-week selector (Mon…Sun chips)
  Widget _buildDaySelector() {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 7,
        itemBuilder: (context, index) {
          final dayDate = _currentWeekStart.add(Duration(days: index));
          final isSelected = index == _selectedDayIndex;
          final isToday =
              dayDate.year == today.year &&
              dayDate.month == today.month &&
              dayDate.day == today.day;

          // Count how many sessions are on this day
          final daySessionCount = _sessions.where((s) {
            return s.date.year == dayDate.year &&
                s.date.month == dayDate.month &&
                s.date.day == dayDate.day;
          }).length;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? aluPrimary : aluCardBg,
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(color: aluAccent, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: aluPrimary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabels[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : aluTextLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dayDate.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : aluTextDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Dot indicator if this day has sessions
                  if (daySessionCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : aluAccent,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Empty state shown when no sessions exist for the selected day
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'No sessions scheduled',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: aluTextLight,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add a new session',
            style: TextStyle(fontSize: 13, color: aluTextLight),
          ),
        ],
      ),
    );
  }

  /// The scrollable list of session cards for the selected day
  Widget _buildSessionList(List<Session> daySessions) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: daySessions.length,
      itemBuilder: (context, index) {
        final session = daySessions[index];
        // We need the global index in _sessions for editing/deleting
        final globalIndex = _sessions.indexOf(session);
        return _buildSessionCard(session, globalIndex);
      },
    );
  }

  /// Individual session card with session details, attendance toggle, and actions
  Widget _buildSessionCard(Session session, int globalIndex) {
    final typeColor = SessionTypes.getColor(session.type);
    final typeIcon = SessionTypes.getIcon(session.type);

    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      // Red background shown when swiping to delete
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: aluWarning,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      // Ask for confirmation before deleting
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Session'),
            content: Text('Remove "${session.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: aluWarning),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        setState(() => _sessions.removeAt(globalIndex));
        widget.onSessionsChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session removed'),
            backgroundColor: aluWarning,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: aluCardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openSessionForm(
            existingSession: session,
            existingIndex: globalIndex,
          ),
          child: Column(
            children: [
              // ---- Top row: type icon + title + action buttons ----
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    // Session type icon in a colored box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 22),
                    ),
                    const SizedBox(width: 12),

                    // Session title & type label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: aluTextDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.type,
                            style: TextStyle(
                              fontSize: 12,
                              color: typeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit button
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: aluTextLight,
                      ),
                      onPressed: () => _openSessionForm(
                        existingSession: session,
                        existingIndex: globalIndex,
                      ),
                      tooltip: 'Edit session',
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: aluWarning,
                      ),
                      onPressed: () => _deleteSession(globalIndex),
                      tooltip: 'Delete session',
                    ),
                  ],
                ),
              ),

              // ---- Time + Location row ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: aluTextLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      session.formattedTimeRange,
                      style: const TextStyle(fontSize: 13, color: aluTextLight),
                    ),
                    if (session.location != null) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: aluTextLight,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          session.location!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: aluTextLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ---- Attendance toggle row (Present / Absent buttons) ----
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: session.attendanceRecorded
                      ? (session.isPresent
                            ? const Color(0xFFECFDF5) // light green
                            : const Color(0xFFFEF2F2)) // light red
                      : Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Attendance:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: aluTextDark,
                      ),
                    ),
                    const Spacer(),
                    // PRESENT button
                    _attendanceButton(
                      label: 'Present',
                      icon: Icons.check_circle,
                      isActive: session.attendanceRecorded && session.isPresent,
                      activeColor: const Color(0xFF059669),
                      onTap: () => _toggleAttendance(globalIndex, true),
                    ),
                    const SizedBox(width: 8),
                    // ABSENT button
                    _attendanceButton(
                      label: 'Absent',
                      icon: Icons.cancel,
                      isActive:
                          session.attendanceRecorded && !session.isPresent,
                      activeColor: aluWarning,
                      onTap: () => _toggleAttendance(globalIndex, false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Small attendance toggle button used inside session cards
  Widget _attendanceButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
