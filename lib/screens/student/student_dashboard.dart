import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mark_attendance.dart';
import 'view_attendance_student.dart';
import 'smart_report_student.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Student Portal", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        //
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              // --- BLUE HEADER SECTION ---
              Container(
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: primaryBlue),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${userData['name'] ?? 'Student'}",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Roll No: ${userData['rollNo'] ?? 'N/A'}",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- MAIN ACTIONS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Tools",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // Mark Attendance Large Card
                    _buildFeatureCard(
                      context,
                      "Mark Attendance",
                      "Scan QR code to mark present",
                      Icons.qr_code_scanner_rounded,
                      primaryBlue,
                      const MarkAttendance(),
                      isLarge: true,
                    ),

                    const SizedBox(height: 15),

                    // History & Reports Row
                    Row(
                      children: [
                        _buildFeatureCard(
                          context,
                          "My History",
                          "View logs",
                          Icons.history_rounded,
                          Colors.indigo.shade700,
                          const ViewAttendanceStudent(),
                        ),
                        const SizedBox(width: 15),
                        _buildFeatureCard(
                          context,
                          "Smart Report",
                          "Analytics",
                          Icons.analytics_rounded,
                          Colors.teal.shade700,
                          const SmartReportStudent(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Smart Attendance Management Application",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // Helper Widget for Cards
  Widget _buildFeatureCard(BuildContext context, String title, String sub, IconData icon, Color color, Widget page, {bool isLarge = false}) {
    return Expanded(
      flex: isLarge ? 0 : 1, // Large card takes full width, small ones split
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLarge ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isLarge ? null : Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: isLarge ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(icon, color: isLarge ? Colors.white : color, size: isLarge ? 40 : 30),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isLarge ? Colors.white : Colors.black87,
                ),
              ),
              if (isLarge)
                Text(
                  sub,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}