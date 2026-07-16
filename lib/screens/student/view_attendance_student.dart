import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewAttendanceStudent extends StatefulWidget {
  const ViewAttendanceStudent({super.key});

  @override
  State<ViewAttendanceStudent> createState() => _ViewAttendanceStudentState();
}

class _ViewAttendanceStudentState extends State<ViewAttendanceStudent> {
  final String studentId = FirebaseAuth.instance.currentUser!.uid;
  final Color primaryBlue = const Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("My Attendance", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Summary Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  "Track your presence per course",
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Attendance List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('studentId', isEqualTo: studentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }


                var records = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    var data = records[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.menu_book_rounded, color: primaryBlue),
                        ),
                        title: FutureBuilder<DocumentSnapshot>(

                          future: FirebaseFirestore.instance.collection('courses').doc(data['courseId']).get(),
                          builder: (context, courseSnap) {
                            String courseName = courseSnap.hasData ? courseSnap.data!['courseName'] : "Loading...";
                            return Text(
                              courseName,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            );
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                const SizedBox(width: 5),
                                Text(data['date'], style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "PRESENT",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
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


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            "No attendance records found yet.",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text("Start scanning QR codes to see logs!"),
        ],
      ),
    );
  }
}