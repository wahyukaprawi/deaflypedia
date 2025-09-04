import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/custom_button.dart';
import '../../utils/custom_button_off.dart';
import '../../utils/custom_progress_bar.dart';
import 'signup_profile_picture_screen.dart';

class SignupKlasifikasiScreen extends StatefulWidget {
  final String username;
  final String age;
  const SignupKlasifikasiScreen(
      {super.key, required this.username, required this.age});

  @override
  State<SignupKlasifikasiScreen> createState() =>
      _SignupKlasifikasiScreenState();
}

class _SignupKlasifikasiScreenState extends State<SignupKlasifikasiScreen> {
  final _formKey = GlobalKey<FormState>();
  String? klasifikasi;
  bool isFormValid = false;

  final List<Map<String, String>> klasifikasiOptions = [
    {"label": "0-25 dB (Ringan)", "value": "0-25 dB"},
    {"label": "26-40 dB (Sedang)", "value": "26-40 dB"},
    {"label": "41-55 dB (Cukup Berat)", "value": "41-55 dB"},
    {"label": "56-70 dB (Berat)", "value": "56-70 dB"},
    {"label": "71-90 dB (Sangat Berat)", "value": "71-90 dB"},
    {"label": ">90 dB (Tuli Total)", "value": ">90 dB"},
  ];

  void _validateForm() {
    setState(() {
      isFormValid = klasifikasi != null && klasifikasi!.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 25),
            child: Row(
              children: [
                InkWell(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 26,
                    color: Color(0XFF118611),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: CustomProgressBar(value: 0.75),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Seberapa besar gangguan\npendengaranmu?',
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF000000),
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilih tingkat ketunarunguan (dB) di bawah ini!',
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF646960),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    child: DropdownButtonFormField<String>(
                      initialValue: klasifikasi,
                      items: klasifikasiOptions
                          .map((option) => DropdownMenuItem<String>(
                                value: option["value"],
                                child: Text(
                                  option["label"]!,
                                  style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0XFF000000),
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                                ),
                              ))
                          .toList(),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        filled: true,
                        fillColor: const Color(0XFFFFFFFF),
                        hintText: 'Pilih',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0XFF818682),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Color(0XFFDADCD9),
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Color(0XFFDADCD9),
                          ),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Color(0XFFDADCD9),
                          ),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(7),
                          ),
                          borderSide: BorderSide(
                            color: Color(0XFFDADCD9),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          klasifikasi = val;
                        });
                        _validateForm();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: isFormValid
                ? CustomButton(
                    ontap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupProfilePictureScreen(
                          username: widget.username,
                          age: widget.age,
                          klasifikasi: klasifikasi ?? "",
                        ),
                      ),
                    ),
                    title: 'Selanjutnya',
                  )
                : CustomButtonOff(
                    ontap: () {},
                    title: 'Selanjutnya',
                  ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
