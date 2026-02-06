import 'package:flutter/material.dart';
import 'models/session.dart';
import 'screens/schedule_screen.dart';

// ALU branding colors used across the app
const Color aluPrimary = Color(0xFF0056A0);
const Color aluAccent = Color(0xFF00AEEF);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Academic App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: aluPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: aluPrimary,
          primary: aluPrimary,
          secondary: aluAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: aluPrimary,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: aluPrimary,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: aluPrimary,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Main app shell with bottom navigation.
/// The shared [_sessions] list lives here so ALL tabs (Dashboard, Schedule)
/// can read/write to the same data — this is what your teammate needs for
/// attendance tracking on the Dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  /// Shared sessions list — used by Dashboard (attendance %) and Schedule screen.
  /// When your teammate merges their Dashboard code, they can read this list
  /// to calculate overall attendance percentage and show the <75% warning.
  final List<Session> _sessions = [];

  /// Called by ScheduleScreen whenever sessions are added/edited/deleted
  /// so the parent rebuilds and the Dashboard picks up the changes too.
  void _onSessionsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Build screens list inside build() so they get the latest state
    final List<Widget> screens = [
      // Tab 0: Dashboard — placeholder for teammate.
      // They can replace this with their widget and use _sessions for attendance.
      _buildDashboardPlaceholder(),
      // Tab 1: Assignments — placeholder for teammate
      const Center(child: Text('Assignments - To be implemented')),
      // Tab 2: Schedule — YOUR screen, receives the shared sessions list
      ScheduleScreen(
        sessions: _sessions,
        onSessionsChanged: _onSessionsChanged,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: aluPrimary,
        unselectedItemColor: Colors.grey,
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

  /// Simple dashboard placeholder that already shows attendance from _sessions.
  /// Your teammate can expand this into the full Dashboard screen.
  Widget _buildDashboardPlaceholder() {
    // Calculate attendance from the shared sessions list
    final recorded = _sessions.where((s) => s.attendanceRecorded).toList();
    final presentCount = recorded.where((s) => s.isPresent).length;
    final percentage =
        recorded.isEmpty ? 100.0 : (presentCount / recorded.length) * 100;
    final isLow = percentage < 75;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: aluPrimary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to ALU Academic App',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Attendance card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLow ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLow ? const Color(0xFFFF5E5E) : const Color(0xFF059669),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isLow ? Icons.warning_amber : Icons.check_circle,
                        color: isLow ? const Color(0xFFFF5E5E) : const Color(0xFF059669),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Attendance: ${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Present: $presentCount / ${recorded.length} sessions',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (isLow)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '⚠ Attendance below 75% — please attend more sessions!',
                        style: TextStyle(color: Color(0xFFFF5E5E), fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Sessions: ${_sessions.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

