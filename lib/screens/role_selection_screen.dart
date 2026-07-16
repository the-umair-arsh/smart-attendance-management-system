import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hamari App ka Theme Colors
    const Color primaryBlue = Color(0xFF0D47A1); // Dark Blue (Logo wala)
    const Color lightBlue = Color(0xFF42A5F5);   // Lite Blue

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // App Name & Welcome
              Text(
                "Welcome to SAMA",
                style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: primaryBlue,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Select your role to get started",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // Role Cards (Admin, Teacher, Student)
              _buildRoleCard(
                context,
                "Admin",
                "Full control & management",
                Icons.admin_panel_settings_rounded,
                [primaryBlue, const Color(0xFF1565C0)],
              ),
              const SizedBox(height: 20),

              _buildRoleCard(
                context,
                "Teacher",
                "Mark & track attendance",
                Icons.co_present_rounded,
                [const Color(0xFF1976D2), lightBlue],
              ),
              const SizedBox(height: 20),

              _buildRoleCard(
                context,
                "Student",
                "View reports & scan QR",
                Icons.school_rounded,
                [lightBlue, const Color(0xFF81D4FA)],
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String subtitle, IconData icon, List<Color> gradientColors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/login',
              arguments: title,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Row(
              children: [
                // Icon Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),

                // Text Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}