import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class SmartReport extends StatelessWidget {
  final String courseId;
  const SmartReport({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Course Report", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('courseId', isEqualTo: courseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _buildEmptyState();
          }


          int totalScans = docs.length;

          return Column(
            children: [
              // --- SUMMARY HEADER ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Text("Total Scans Recorded", style: GoogleFonts.poppins(color: Colors.white70)),
                    Text("$totalScans", style: GoogleFonts.poppins(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- LOGS LIST ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(data['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Date: ${data['date']}"),
                        trailing: Text(data['rollNo'], style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),

              // Export Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF Export feature coming soon!")));
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: const Text("EXPORT AS PDF", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text("No attendance history found for this course.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}