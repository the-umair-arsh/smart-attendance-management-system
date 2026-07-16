import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  bool isScanCompleted = false;
  bool isProcessing = false;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  // Fetches the unique hardware ID for device binding
  Future<String?> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (e) {
      debugPrint("Error getting device ID: $e");
    }
    return null;
  }

  // Processes raw QR data and validates attendance requirements
  void _processQRData(String rawData) async {
    if (isScanCompleted || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      // 1. Parse QR Data (Expected Format: CourseID | Timestamp)
      final List<String> parts = rawData.split('|');
      if (parts.length < 2) throw "Invalid QR Code Format";

      final String courseId = parts[0];
      final String studentUid = FirebaseAuth.instance.currentUser!.uid;
      final String? currentDeviceId = await _getDeviceId();

      final now = DateTime.now();
      final String todayDate = "${now.day}-${now.month}-${now.year}";

      // 2. Retrieve student profile to verify device binding
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(studentUid);
      DocumentSnapshot userDoc = await userRef.get();

      if (!userDoc.exists) throw "User profile not found!";
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // --- DEVICE BINDING LOGIC ---
      if (userData['deviceId'] == null) {
        // Initial scan: Link the current device to this student account
        await userRef.update({'deviceId': currentDeviceId});
      } else if (userData['deviceId'] != currentDeviceId) {
        // Unauthorized device detected
        _showStatusDialog(
            title: "Proxy Detected!",
            message: "You can only mark attendance from your registered device.",
            isError: true
        );
        return;
      }

      // 3. Prevent duplicate attendance for the same course on the same day
      var existing = await FirebaseFirestore.instance
          .collection('attendance')
          .where('courseId', isEqualTo: courseId)
          .where('studentId', isEqualTo: studentUid)
          .where('date', isEqualTo: todayDate)
          .get();

      if (existing.docs.isNotEmpty) {
        _showStatusDialog(
            title: "Already Marked!",
            message: "Your attendance for today has already been recorded.",
            isError: true
        );
        return;
      }

      // 4. Record the attendance in Firestore
      await FirebaseFirestore.instance.collection('attendance').add({
        'courseId': courseId,
        'studentId': studentUid,
        'studentName': userData['name'],
        'rollNo': userData['rollNo'],
        'date': todayDate,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Present',
      });

      // 5. Ensure student is enrolled in the course list
      await FirebaseFirestore.instance.collection('courses').doc(courseId).update({
        'students': FieldValue.arrayUnion([studentUid])
      });

      setState(() => isScanCompleted = true);
      _showStatusDialog(
          title: "Success!",
          message: "Attendance marked successfully for ${userData['name']}.",
          isError: false
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Attendance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQRData(barcode.rawValue!);
                }
              }
            },
          ),
          Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                "Align QR Code within the frame",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Spacer(),
              if (isProcessing)
                const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 50),
              const Text(
                "SAMA Security: Device Binding Active",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusDialog({required String title, required String message, required bool isError}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (!isError) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isError ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}