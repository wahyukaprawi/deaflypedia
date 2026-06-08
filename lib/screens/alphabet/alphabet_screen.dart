import 'package:deaflypedia_app/screens/alphabet/detail_alphabet_screen.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  bool _isOpeningModal = false;

  Future<void> _handleLetterTap(String letter) async {
    // Jika sedang memproses, abaikan klik selanjutnya
    if (_isOpeningModal) return;

    setState(() {
      _isOpeningModal = true;
    });

    try {
      showDetailAlphabet(context, letter);
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningModal = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(bgAlphabet),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 88),
                Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(text: 'Alphabet\n'),
                      TextSpan(text: 'A–Z'),
                    ],
                  ),
                  style: GoogleFonts.poppins(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 120),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                  decoration: const BoxDecoration(
                    color: Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: List.generate(25, (index) {
                          // Ubah di bagian pemanggilan fungsi di sini
                          return _buildLetterBox(
                            context,
                            String.fromCharCode(65 + index),
                            _isOpeningModal
                                ? null
                                : () => _handleLetterTap(
                                    String.fromCharCode(65 + index)),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Spacer(flex: 2),
                          // Ubah juga untuk huruf Z
                          _buildLetterBox(
                            context,
                            "Z",
                            _isOpeningModal
                                ? null
                                : () => _handleLetterTap("Z"),
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Tambahkan parameter onTap pada method helper ini
Widget _buildLetterBox(
    BuildContext context, String letter, VoidCallback? onTap) {
  return InkWell(
    focusColor: Colors.transparent,
    hoverColor: Colors.transparent,
    highlightColor: Colors.transparent,
    overlayColor: WidgetStateProperty.all(Colors.transparent),
    onTap: onTap, // Menggunakan callback yang di-passing
    child: Container(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.07,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0XFF369A44),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: GoogleFonts.fuzzyBubbles(
          color: const Color(0xFFFFFFFF),
          fontSize: 38,
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
