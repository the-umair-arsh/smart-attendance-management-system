import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/role');
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    const Color logoBlue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.white, // PURE WHITE
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(flex: 4),

            // --- LOGO (Ab ye seamless hai) ---
            Image.asset(
              'assets/icon/icon.png',
              height: 120, // Size
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 15), //

            // --- APP NAME (Compact & Professional) ---
            Text(
              "SAMA",
              style: GoogleFonts.montserrat(
                fontSize: 28, // Chota size as requested
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: logoBlue,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Smart Attendance Management System",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(flex: 3),

            // --- LOADING ANIMATION (Matching Color) ---
            const SpinKitThreeBounce(
              color: logoBlue,
              size: 25.0,
            ),

            const Spacer(flex: 2),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Text(
                    "Developed by",
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    "TUA Software Corporation",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}