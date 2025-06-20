




import 'package:roadside_assistance/Company%20Side/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:roadside_assistance/User%20Side/side_drawer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF001E62);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: SideDrawer(),
      body: Column(
        children: [
          // Gradient Header
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001E62), Color(0xFF3A4D8F)],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/profile_placeholder.jpg'),
                      radius: 18,
                    ),
                  ),
                ),
              ],
              iconTheme: const IconThemeData(color: Colors.white),
            ),
          ),
          // Notifications List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return NotificationCard(
                    notification: notifications[index],
                    primaryColor: primaryColor,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, String> notification;
  final Color primaryColor;

  const NotificationCard({required this.notification, required this.primaryColor, super.key});

  Color _iconBgColor(String? type) {
    switch (type) {
      case 'welcome':
        return Colors.green.shade100;
      case 'update':
        return Colors.blue.shade100;
      default:
        return primaryColor.withOpacity(0.1);
    }
  }

  Color _iconColor(String? type) {
    switch (type) {
      case 'welcome':
        return Colors.green.shade700;
      case 'update':
        return Colors.blue.shade700;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    if (notification['icon'] == 'welcome') {
      iconData = Icons.emoji_emotions_outlined;
    } else if (notification['icon'] == 'update') {
      iconData = Icons.system_update_alt;
    } else {
      iconData = Icons.notifications;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Card(
        elevation: 5,
        shadowColor: primaryColor.withOpacity(0.10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _iconBgColor(notification['icon']),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(iconData, color: _iconColor(notification['icon']), size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 15.5,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.check_circle, color: Colors.grey[300], size: 22),
                  const SizedBox(height: 12),
                  Text(
                    notification['time'] ?? '',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final List<Map<String, String>> notifications = [
  {
    'title': 'Welcome!',
    'message': 'Welcome to your dashboard. We are glad to have you on board!',
    'time': 'Just now',
    'icon': 'welcome',
  },
  {
    'title': 'App Update',
    'message': 'The app has been updated with new features. Check them out!',
    'time': '2 min ago',
    'icon': 'update',
  },
];

