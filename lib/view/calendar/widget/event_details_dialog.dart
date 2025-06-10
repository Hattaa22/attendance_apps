import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/color/colors.dart';
import '../model/event.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;
  final DateTime selectedDay;

  const EventDetailsDialog({
    super.key,
    required this.event,
    required this.selectedDay,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: greyMainColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
                      'Meeting details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Meeting title', event.title),
                  _buildDetailRow('Meeting type', event.mode.toLowerCase()),
                  _buildDetailRow('Department', event.department),
                  _buildDetailRow('Head department', 'head department'),
                  _buildDetailRow('Team department', 'Team adit'),
                  _buildDetailRow('Department team member', 'Adit, Sopo, Jarwo'),
                  _buildDetailRow('Date', DateFormat('dd/MM/yyyy').format(selectedDay)),
                  _buildDetailRow('Time', event.time),
                  if (event.mode.toLowerCase() == 'online') ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Link & Description:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'https://zoom.us/meeting/abc123',
                      style: TextStyle(
                        fontSize: 14,
                        color: blueMainColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueMainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Okay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}