import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fortis_apps/core/color/colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Clock in successful',
      'description': 'You have successfully clocked in at 08:00 AM.',
      'dateTime': '16 June 2025 | 08:01 AM',
      'status': 'Clock In',
      'read': false,
    },
    {
      'title': 'Clock Out successful',
      'description':
          'You have successfully clocked out at 04:00 AM. Thank you for your hard work today!!',
      'dateTime': '15 June 2025 | 04:01 AM',
      'status': 'Clock Out',
      'read': true,
    },
    {
      'title': 'The "Design meeting to client"',
      'description':
          'has been successfully scheduled for Wednesday, 16 June, 2025 at 11:00 AM. Don\'t forget to be on time!',
      'dateTime': '16 June 2025 | 11:01 AM',
      'status': 'Other',
      'read': true,
    },
    {
      'title': 'The "Leave"',
      'description':
          'has been sent. The department and team member will receive an email containing details of the requested leave.',
      'dateTime': '15 June 2025 | 04:01 AM',
      'status': 'Other',
      'read': false,
    },
    {
      'title': 'Your new password',
      'description':
          'has been successfully saved. Please use the new password next time you log in.',
      'dateTime': '16 June 2025 | 11:01 AM',
      'status': 'Other',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteMainColor,
      appBar: AppBar(
        backgroundColor: whiteMainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isRead = notif['read'] as bool;
          final bgColor = isRead ? Colors.white : const Color(0xFFE8F1FF);
          final statusColor = notif['status'] == 'Clock In'
              ? const Color.fromARGB(168, 33, 149, 243)
              : notif['status'] == 'Clock Out'
                  ? const Color.fromARGB(183, 255, 38, 23)
                  : Colors.black87;

          return GestureDetector(
            onTap: () {
              if (!isRead) {
                setState(() {
                  notifications[index]['read'] = true;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icon/Done_ring_round_fill.png',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notif['status'] == 'Clock In' ||
                            notif['status'] == 'Clock Out') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              notif['title'],
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notif['description'],
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ] else ...[
                          RichText(
                            text: TextSpan(
                              text: notif['title'] + ' ',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: notif['description'],
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          notif['dateTime'],
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
}
