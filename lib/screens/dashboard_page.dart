import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final String email;
  final List<String> selectedCourses;

  const DashboardPage({
    super.key,
    required this.email,
    required this.selectedCourses,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Calculate attendance percentage (mock data for demonstration)
  double attendancePercentage = 65.0; // Below 75% threshold, so warning shows

  // Map of courses to their classes and assignments
  late Map<String, Map<String, dynamic>> courseData;
  late String selectedCourse;

  // Track which assignment items are expanded
  Set<String> expandedAssignments = {};

  @override
  void initState() {
    super.initState();
    // Initialize course data with classes and assignments for each course
    courseData = {
      'Introduction to Linux and Intro to Git': {
        'classes': [
          {
            'title': 'Introduction to Linux',
            'time': '09:00 AM',
            'location': 'Room 101',
          },
        ],
        'assignments': [
          {'title': 'Quiz 1', 'dueDate': 'Due Feb 26'},
        ],
      },
      'Introduction to Python Programming': {
        'classes': [
          {
            'title': 'Python Programming',
            'time': '11:30 AM',
            'location': 'Lab 203',
          },
        ],
        'assignments': [
          {'title': 'Assignment 2', 'dueDate': 'Due Feb 26'},
        ],
      },
      'Front End Web Development': {
        'classes': [
          {
            'title': 'Web Development Basics',
            'time': '02:00 PM',
            'location': 'Room 305',
          },
        ],
        'assignments': [
          {'title': 'Project 1', 'dueDate': 'Due Mar 05'},
        ],
      },
    };

    // Set initial selected course to "All Selected Courses"
    selectedCourse = 'All Selected Courses';
  }

  // Get current course's classes (handles both single course and all courses)
  List<Map<String, String>> get currentClasses {
    if (selectedCourse == 'All Selected Courses') {
      // Return all classes from all selected courses
      List<Map<String, String>> allClasses = [];
      for (var course in widget.selectedCourses) {
        allClasses.addAll(
          List<Map<String, String>>.from(courseData[course]?['classes'] ?? []),
        );
      }
      return allClasses;
    } else {
      // Return classes for selected course only
      return List<Map<String, String>>.from(
        courseData[selectedCourse]?['classes'] ?? [],
      );
    }
  }

  // Get current course's assignments (handles both single course and all courses)
  List<Map<String, String>> get currentAssignments {
    if (selectedCourse == 'All Selected Courses') {
      // Return all assignments from all selected courses
      List<Map<String, String>> allAssignments = [];
      for (var course in widget.selectedCourses) {
        allAssignments.addAll(
          List<Map<String, String>>.from(
            courseData[course]?['assignments'] ?? [],
          ),
        );
      }
      return allAssignments;
    } else {
      // Return assignments for selected course only
      return List<Map<String, String>>.from(
        courseData[selectedCourse]?['assignments'] ?? [],
      );
    }
  }

  // Helper method to get course name from assignment title
  String _getCourseName(String assignmentTitle) {
    if (assignmentTitle.contains('Quiz')) {
      return 'Introduction to Linux';
    } else if (assignmentTitle.contains('Assignment')) {
      return 'Introduction to Python Programming';
    } else if (assignmentTitle.contains('Project')) {
      return 'Front End Web Development';
    }
    return 'Unknown Course';
  }

  @override
  Widget build(BuildContext context) {
    // Check if attendance warning should be shown
    bool showAttendanceWarning = attendancePercentage < 75.0;

    return Scaffold(
      backgroundColor: const Color(0xFF000d26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000d26),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "All Selected Courses" Heading with Dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Selected Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: selectedCourse,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCourse = newValue;
                              });
                            }
                          },
                          dropdownColor: const Color(0xFF001a4d),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          items: [
                            // Add "All Selected Courses" option at the beginning
                            const DropdownMenuItem<String>(
                              value: 'All Selected Courses',
                              child: Text('All Selected Courses'),
                            ),
                            // Add divider
                            const DropdownMenuItem<String>(
                              enabled: false,
                              value: '',
                              child: Divider(),
                            ),
                            // Add individual courses
                            ...widget.selectedCourses
                                .map<DropdownMenuItem<String>>((String course) {
                                  return DropdownMenuItem<String>(
                                    value: course,
                                    child: Text(course),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // AT RISK WARNING Alert
                  if (showAttendanceWarning)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935), // Red warning color
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFC62828),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AT RISK WARNING',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your attendance is ${attendancePercentage.toStringAsFixed(1)}%. Please attend more classes.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Three Metric Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _MetricCard(
                        value: '4',
                        label: 'Courses',
                        icon: Icons.assignment,
                      ),
                      _MetricCard(
                        value: '7',
                        label: 'Late Subs',
                        icon: Icons.book,
                      ),
                      _MetricCard(
                        value: '1',
                        label: 'Upcoming',
                        icon: Icons.schedule,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Today's Task subtitle
                  const Text(
                    'Today\'s Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Assignments Section: White box containing Assignments
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Assignments
                        const Text(
                          'Assignments',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Assignments Items for selected course with expandable dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...currentAssignments.map((assignment) {
                              final assignmentKey = assignment['title']!;
                              final isExpanded = expandedAssignments.contains(
                                assignmentKey,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header - Clickable to expand/collapse
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isExpanded) {
                                              expandedAssignments.remove(
                                                assignmentKey,
                                              );
                                            } else {
                                              expandedAssignments.add(
                                                assignmentKey,
                                              );
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      assignment['title']!,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.calendar_today,
                                                          size: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          assignment['dueDate']!,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                isExpanded
                                                    ? Icons.keyboard_arrow_up
                                                    : Icons.keyboard_arrow_down,
                                                color: Colors.grey[600],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Expanded Content
                                      if (isExpanded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Colors.grey[300]!,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Details section
                                              Text(
                                                'Details',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Course: ${_getCourseName(assignment['title']!)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Type: Assignment',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Status: Pending',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // Action buttons
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFF0066cc,
                                                            ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Opening ${assignment['title']}',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'View',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        side: const BorderSide(
                                                          color: Color(
                                                            0xFF0066cc,
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 8,
                                                            ),
                                                      ),
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Submitted ${assignment['title']}',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Submit',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Color(
                                                            0xFF0066cc,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Scroll Down Indicator at the bottom right
          Positioned(
            bottom: 100,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF000d26),
                size: 28,
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF001a4d),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Announcements',
          ),
        ],
      ),
    );
  }
}

// Metric Card Widget
class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF001a4d),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF003366), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
