import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'generate_qr.dart';
import 'view_attendance.dart';
import 'smart_report.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String? selectedCourseId;
  String? selectedCourseName;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Teacher Portal", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white, // Text/Icons color fix
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              // --- BLUE HEADER SECTION ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: primaryBlue),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome, ${userData['name'] ?? 'Professor'}",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(userData['department'] ?? "Faculty Member",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- COURSE SELECTION ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('courses')
                      .where('teacherId', isEqualTo: user?.uid)
                      .snapshots(),
                  builder: (context, courseSnapshot) {
                    if (!courseSnapshot.hasData) return const LinearProgressIndicator();
                    var courses = courseSnapshot.data!.docs;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text("Select Course First"),
                          value: selectedCourseId,
                          isExpanded: true,
                          items: courses.map((c) {
                            return DropdownMenuItem(value: c.id, child: Text(c['courseName']));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCourseId = val;
                              selectedCourseName = courses.firstWhere((d) => d.id == val)['courseName'];
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- MAIN CONTROLS ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Attendance Management",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 15),

                      // Generate QR Card
                      _buildMainActionCard(
                        context,
                        "Generate QR Code",
                        selectedCourseId == null ? "Select a course above" : "Start session for $selectedCourseName",
                        Icons.qr_code_scanner_rounded,
                        const Color(0xFF1565C0),
                        // Fix: Passing both courseId and courseName
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => GenerateQR(courseId: selectedCourseId!, courseName: selectedCourseName!))),
                        isActive: selectedCourseId != null,
                      ),

                      const SizedBox(height: 15),

                      // Bottom Row Cards
                      Row(
                        children: [
                          _buildSmallActionCard(
                            context,
                            "View History",
                            Icons.history_rounded,
                            Colors.blue.shade700,

                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => ViewAttendance(courseId: selectedCourseId!))),
                            isActive: selectedCourseId != null,
                          ),
                          const SizedBox(width: 15),
                          _buildSmallActionCard(
                            context,
                            "Smart Report",
                            Icons.analytics_outlined,
                            Colors.indigo.shade700,
                            // Fix: Passing courseId
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => SmartReport(courseId: selectedCourseId!))),
                            isActive: selectedCourseId != null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Action Card Widgets...
  Widget _buildMainActionCard(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap, {bool isActive = true}) {
    return InkWell(
      onTap: isActive ? onTap : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 45),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(sub, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, {bool isActive = true}) {
    return Expanded(
      child: InkWell(
        onTap: isActive ? onTap : null,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 10),
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}