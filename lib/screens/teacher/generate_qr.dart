import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class GenerateQR extends StatefulWidget {
  final String courseId;
  final String courseName;

  const GenerateQR({super.key, required this.courseId, required this.courseName});

  @override
  State<GenerateQR> createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  String qrData = "";
  bool isSessionStarted = false;

  void _startNewSession() {
    setState(() {
      qrData = "${widget.courseId}|${DateTime.now().millisecondsSinceEpoch}";
      isSessionStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Generate Attendance", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.courseName,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
            const SizedBox(height: 5),
            const Text("Point the screen towards students", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 50),

            if (!isSessionStarted) ...[
              const Icon(Icons.qr_code_2_rounded, size: 180, color: Colors.blueGrey),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: _startNewSession,
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text("START SESSION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: const Size(250, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: primaryBlue, width: 4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 260.0,
                  gapless: false,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton.filled(
                        onPressed: _startNewSession,
                        icon: const Icon(Icons.refresh_rounded),
                        style: IconButton.styleFrom(backgroundColor: Colors.orange.shade700),
                      ),
                      const Text("Rotate QR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),

                  Column(
                    children: [
                      IconButton.filled(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.stop_rounded),
                        // FIX: style use karna parta hai
                        style: IconButton.styleFrom(backgroundColor: Colors.red.shade700),
                      ),
                      const Text("End Session", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Card(
                color: Color(0xFFE3F2FD),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: primaryBlue, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Device Binding is active. Only registered student phones can scan this code.",
                          style: TextStyle(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}