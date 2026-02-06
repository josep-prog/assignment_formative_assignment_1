import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ===== ATTENDANCE MODELS =====

enum AttendanceStatus {
  present,
  absent,
}

class Session {
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final AttendanceStatus status;

  Session({
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}

// ===== ROOT APP =====

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Academic Platform',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

// ===== MAIN SCAFFOLD (bottom nav + attendance logic) =====

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Session> _sessions = [
    Session(
      title: 'Programming Fundamentals',
      date: DateTime(2026, 2, 1),
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 30),
      status: AttendanceStatus.present,
    ),
    Session(
      title: 'User Experience Design',
      date: DateTime(2026, 2, 2),
      startTime: const TimeOfDay(hour: 11, minute: 0),
      endTime: const TimeOfDay(hour: 12, minute: 0),
      status: AttendanceStatus.absent,
    ),
    Session(
      title: 'Web Development Lab',
      date: DateTime(2026, 2, 3),
      startTime: const TimeOfDay(hour: 14, minute: 0),
      endTime: const TimeOfDay(hour: 15, minute: 30),
      status: AttendanceStatus.present,
    ),
  ];

  double get attendancePercentage {
    if (_sessions.isEmpty) return 0;
    final attended =
        _sessions.where((s) => s.status == AttendanceStatus.present).length;
    return (attended / _sessions.length) * 100;
  }

  void _toggleAttendance(int index) {
    setState(() {
      final current = _sessions[index];
      final newStatus = current.status == AttendanceStatus.present
          ? AttendanceStatus.absent
          : AttendanceStatus.present;

      _sessions[index] = Session(
        title: current.title,
        date: current.date,
        startTime: current.startTime,
        endTime: current.endTime,
        status: newStatus,
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(attendancePercentage: attendancePercentage),
      const AssignmentsScreen(),
      ScheduleScreen(
        sessions: _sessions,
        onToggleAttendance: _toggleAttendance,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Academic Platform'),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}

// ===== SCREEN 1: DASHBOARD =====

class DashboardScreen extends StatelessWidget {
  final double attendancePercentage;

  const DashboardScreen({
    super.key,
    required this.attendancePercentage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLow = attendancePercentage < 75;
    final now = DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today: ${now.day}/${now.month}/${now.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Academic Week: Week 5'),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Tracking',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${attendancePercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isLow ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isLow ? Icons.warning : Icons.check_circle,
                        color: isLow ? Colors.red : Colors.green,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLow
                        ? 'Warning: Attendance below 75%.'
                        : 'Good standing: Attendance above 75%.',
                    style: TextStyle(
                      color: isLow ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Today\'s Sessions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This will show today\'s scheduled classes.'),
          const SizedBox(height: 16),
          const Text(
            'Upcoming Assignments (next 3 days)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('This will list upcoming assignments.'),
        ],
      ),
    );
  }
}

// ===== SCREEN 2: ASSIGNMENTS (placeholder) =====

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Assignments screen (to be implemented by teammates)'),
    );
  }
}

// ===== SCREEN 3: SCHEDULE =====

class ScheduleScreen extends StatelessWidget {
  final List<Session> sessions;
  final void Function(int index) onToggleAttendance;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onToggleAttendance,
  });

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No sessions scheduled yet.'));
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isPresent = session.status == AttendanceStatus.present;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(session.title),
            subtitle: Text(
              '${session.date.day}/${session.date.month}/${session.date.year} '
              '${_formatTimeOfDay(session.startTime)}'
              ' - '
              '${_formatTimeOfDay(session.endTime)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isPresent ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => onToggleAttendance(index),
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Toggle attendance',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
