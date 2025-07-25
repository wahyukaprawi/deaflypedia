// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DetailAlphabetScreen extends StatelessWidget {
  final String letter;
  final String gifUrl;

  const DetailAlphabetScreen({
    super.key,
    required this.letter,
    required this.gifUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0XFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 108,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0XFF000000),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Transform.translate(
              offset: const Offset(2.5, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0XFFF5F6F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.close_rounded, size: 24),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Text(
                letter,
                style: GoogleFonts.poppins(
                  color: const Color(0XFF000000),
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Image.network(
                    gifUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Gagal memuat GIF',
                          style: GoogleFonts.poppins(
                            color: const Color(0XFF000000),
                          ),
                        ),
                      );
                    },
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

void showDetailAlphabet(BuildContext context, String letter) async {
  final doc =
      await FirebaseFirestore.instance.collection('alphabet').doc(letter).get();

  final String gifUrl = doc['gifUrl'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => SizedBox(
      height: 340,
      child: DetailAlphabetScreen(
        letter: letter,
        gifUrl: gifUrl,
      ),
    ),
  );
}
