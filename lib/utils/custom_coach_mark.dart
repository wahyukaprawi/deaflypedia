import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCoachMark extends StatelessWidget {
  final String title;
  final String desc;
  final AssetImage icImage;
  final String skip;
  final String next;
  final Function() onSkip;
  final Function() onNext;

  const CustomCoachMark({
    super.key,
    required this.title,
    required this.desc,
    required this.icImage,
    required this.skip,
    required this.next,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0XFFFFFFFF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                width: 20,
                height: 20,
                image: icImage,
              ),
              const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF000000),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            desc,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0XFF646960),
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: onSkip,
                child: Text(
                  skip,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0XFF118611),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: onNext,
                child: Container(
                  width: 60,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color(0XFF118611),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    next,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0XFFFFFFFF),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
