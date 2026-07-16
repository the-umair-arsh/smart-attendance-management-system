import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherProfileScreen extends StatelessWidget {
  final String teacherId;
  final String teacherName;

  const TeacherProfileScreen({super.key, required this.teacherId, required this.teacherName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(teacherName), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          Text("Assigned Courses", style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .where('teacherId', isEqualTo: teacherId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var courses = snapshot.data!.docs;
                if (courses.isEmpty) return const Center(child: Text("No courses assigned to this teacher."));

                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    var course = courses[index];
                    return ListTile(
                      leading: const Icon(Icons.book, color: Colors.blue),
                      title: Text(course['courseName']),
                      subtitle: Text("Code: ${course['courseCode']}"),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}