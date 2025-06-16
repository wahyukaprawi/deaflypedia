import 'package:deaflypedia_app/screens/auth/signup_name_screen.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:deaflypedia_app/utils/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 30),
        child: Column(
          children: [
            const Spacer(),
            const Image(
              width: 250,
              image: AssetImage(ilustrasi1),
            ),
            const SizedBox(height: 40),
            Text(
              'Ayo Belajar Bersama!',
              style: GoogleFonts.poppins(
                color: const Color(0XFF000000),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deaflypedia adalah media pembelajaran interaktif yang menyatukan materi, latihan, dan pembelajaran visual yang menyenangkan!',
              style: GoogleFonts.poppins(
                color: const Color(0XFF74737A),
                fontSize: 12,
                fontWeight: FontWeight.normal,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 100),
            CustomButton(
              ontap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (constext) => const SignupNameScreen(),
                ),
              ),
              title: 'Mulai',
            ),
          ],
        ),
      ),
    );
  }
}
