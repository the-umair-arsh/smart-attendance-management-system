import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_course_screen.dart';
import 'course_details_screen.dart';

class ManageSubjects extends StatefulWidget {
  const ManageSubjects({super.key});

  @override
  State<ManageSubjects> createState() => _ManageSubjectsState();
}

class _ManageSubjectsState extends State<ManageSubjects> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      appBar: AppBar(
        title: Text("All Courses", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Course or Code...",
                prefixIcon: const Icon(Icons.search, color: primaryBlue),
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var docs = snapshot.data!.docs.where((d) {
                  var data = d.data() as Map<String, dynamic>;
                  var name = (data['courseName'] ?? "").toString().toLowerCase();
                  var code = (data['courseCode'] ?? "").toString().toLowerCase();
                  return name.contains(searchQuery) || code.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    var course = docs[index].data() as Map<String, dynamic>;
                    String courseId = docs[index].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: const Icon(Icons.book, color: primaryBlue, size: 30),
                        title: Text(course['courseName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Code: ${course['courseCode']} | Teacher: ${course['teacherName'] ?? 'N/A'}"),

                        // --- DELETE BUTTON ---
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(courseId, course['courseName'] ?? 'this course'),
                        ),

                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseData: course, courseId: courseId)));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen())),
        label: const Text("Add Course", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryBlue,
      ),
    );
  }

  // --- DELETE CONFIRMATION DIALOG (YES/NO) ---
  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Warning!"),
          ],
        ),
        content: Text("Are you sure you want to delete '$name'? This will remove the course and its attendance data."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No, Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('courses').doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Course deleted successfully."), backgroundColor: Colors.redAccent),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}