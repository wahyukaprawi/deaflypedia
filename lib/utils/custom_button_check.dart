import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonCheck extends StatelessWidget {
  final String title;
  final Function() onTap;
  const CustomButtonCheck(
      {super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0XFF118611),
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0XFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
