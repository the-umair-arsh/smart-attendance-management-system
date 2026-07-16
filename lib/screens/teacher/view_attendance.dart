import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewAttendance extends StatelessWidget {
  final String courseId;
  const ViewAttendance({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final String todayDate = "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Attendance", style: GoogleFonts.montserrat()),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('courseId', isEqualTo: courseId)
            .where('date', isEqualTo: todayDate)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No one has scanned yet."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(data['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Roll No: ${data['rollNo']}"),
                  trailing: const Text("Present", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}