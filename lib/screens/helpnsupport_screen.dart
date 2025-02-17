import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF5D7BD5)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Help & Support',
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D7BD5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Welcome to Brillio Support',
                style: GoogleFonts.quicksand(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA873E8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We are here to help you with any questions or concerns you may have about using Brillio. Our support team is available during business hours to assist you with technical issues, account management, or any other queries.',
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Contact Us',
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D7BD5),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _makePhoneCall('+919356943929'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Color(0xFFA873E8),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '+91 9356943929',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          color: const Color(0xFF5D7BD5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => _sendEmail('tanmaydalvi3929@gmail.com'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: Color(0xFFA873E8),
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'tanmaydalvi3929@gmail.com',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          color: const Color(0xFF5D7BD5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}