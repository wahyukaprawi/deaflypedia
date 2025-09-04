import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/assert_image.dart';
import '../../utils/custom_button.dart';
import '../home/home_screen.dart';

class SignupFinishScreen extends StatefulWidget {
  final String username;
  const SignupFinishScreen(
      {super.key,
      required this.username,});

  @override
  State<SignupFinishScreen> createState() => _SignupFinishScreenState();
}

class _SignupFinishScreenState extends State<SignupFinishScreen> {
  String capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  final List<String> _encodedNames = [
    "c3lpZmE=",   
    "Y2lwYQ==",
    "Y2lwYWE=" 
  ];

  List<String> get specialNames =>
      _encodedNames.map((e) => utf8.decode(base64.decode(e))).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 30),
            child: Column(
              children: [
                const Spacer(),
                const Image(
                  width: 250,
                  image: AssetImage(ilustrasi2),
                ),
                const SizedBox(height: 40),
                Text(
                  'Selamat Datang, ${capitalize(widget.username)}!',
                  style: GoogleFonts.poppins(
                    color: const Color(0XFF000000),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kami sangat senang Anda bergabung bersama\nkami dalam misi memperkaya kosakata\nmelalui Deaflypedia.',
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
                      builder: (constext) => const HomeScreen(),
                    ),
                  ),
                  title: 'Mulai Sekarang',
                ),
              ],
            ),
          ),
          if (specialNames.contains(widget.username.toLowerCase()))
            Positioned(
              top: 70,
              right: 20,
              child: Text(
                "hallo kerucill",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0XFF74737A),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
