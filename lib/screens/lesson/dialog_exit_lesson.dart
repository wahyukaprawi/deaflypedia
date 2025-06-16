// ignore_for_file: use_build_context_synchronously

import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DialogExitLesson extends StatelessWidget {
  const DialogExitLesson({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: 340,
        decoration: const BoxDecoration(
          color: Color(0XFFFFFFFF),
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 25),
            const Image(
              width: 100,
              height: 100,
              image: AssetImage(icCircleExit),
            ),
            const SizedBox(height: 20),
            Text(
              'Keluar Pembelajaran',
              style: GoogleFonts.poppins(
                color: const Color(0XFF000000),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Anda yakin ingin keluar sekarang?',
              style: GoogleFonts.poppins(
                color: const Color(0XFF646960),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Divider(
              thickness: 1,
              color: Color(0XFFEBEBEB),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0XFFC2EABD),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Keluar',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0XFF118611),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: const Color(0XFFEBEBEB),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Lanjut belajar',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0XFF000000),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
