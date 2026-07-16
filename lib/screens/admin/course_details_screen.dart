import 'package:flutter/material.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> courseData;
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseData, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseData['courseName'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Code: ${courseData['courseCode']}", style: const TextStyle(color: Colors.grey)),
            const Divider(height: 40),
            const Text("Assigned Teacher:", style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(courseData['teacherName'] ?? "Not Assigned"),
              subtitle: const Text("Instructor"),
            ),
            const Spacer(),
            //
          ],
        ),
      ),
    );
  }
}