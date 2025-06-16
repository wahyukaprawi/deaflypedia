import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtonOff extends StatelessWidget {
  final Function() ontap;
  final String title;
  const CustomButtonOff({super.key, required this.ontap, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      onTap: ontap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0XFF87C286),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0XFFFEFEFD),
              ),
            ),
            const Spacer(),
            Container(
              width: 35,
              height: 35,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0XFF7EB17E),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0XFFFEFEFD),
              ),
            )
          ],
        ),
      ),
    );
  }
}
