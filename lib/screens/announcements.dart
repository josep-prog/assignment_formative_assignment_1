import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2C5A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2C5A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Announcements Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2C5A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Reminder: Project Deadlines
              _buildAnnouncementCard(
                title: 'Reminder: Project Deadlines',
                description:
                    'Denaturation of Software Engineering Considering all deliverable beyond will listed in',
                color: const Color(0xFFF5F5F5),
              ),
              const SizedBox(height: 16),
              // Upcoming Industry Talk
              _buildAnnouncementCard(
                title: 'Upcoming Industry Talk',
                description: 'Farming arrow my id f id state your convenience',
                color: const Color(0xFFF5F5F5),
              ),
              const SizedBox(height: 16),
              // Update for All Students
              _buildAnnouncementCard(
                title: 'Update for All Students',
                description:
                    'See additional online courses for enlist in your coursework',
                color: const Color(0xFFF5F5F5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2C5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
