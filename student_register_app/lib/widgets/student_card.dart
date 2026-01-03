
import 'package:flutter/material.dart';
import '../../models/student_model.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap, required String photoUrl, required Widget photoWidget,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = {
      'Approved': Colors.green,
      'Pending': Colors.orange,
      'Rejected': Colors.red,
    }[student.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  student.firstName[0] + student.lastName[0],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student.firstName} ${student.lastName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Text(
                    //   // student.email,
                    //   // style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    // ),
                    if (student.major != null)
                      Text(
                        '${student.major} • ${student.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                  ],
                ),
              ),

              // Status chip
              Chip(
                label: Text(student.status, style: const TextStyle(fontSize: 11)),
                backgroundColor: statusColor.withOpacity(0.2),
                labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}