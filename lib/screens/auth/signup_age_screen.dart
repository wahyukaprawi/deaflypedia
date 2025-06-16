import 'package:deaflypedia_app/screens/auth/signup_profile_picture_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/custom_button.dart';
import '../../utils/custom_button_off.dart';
import '../../utils/custom_progress_bar.dart';

class SignupAgeScreen extends StatefulWidget {
  final String username;
  const SignupAgeScreen({super.key, required this.username});

  @override
  State<SignupAgeScreen> createState() => _SignupAgeScreenState();
}

class _SignupAgeScreenState extends State<SignupAgeScreen> {
  final _formKey = GlobalKey<FormState>();
  String age = '';
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
  }

  void _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isFormValid = true;
      });
    } else {
      setState(() {
        isFormValid = false;
      });
    }
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
                  child: CustomProgressBar(value: 0.66),
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
                    'Berapa umur Anda saat ini?',
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF000000),
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Masukkan umur Anda pada kolom di bawah ini!',
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF646960),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Form(
                    key: _formKey,
                    onChanged: _validateForm,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0XFF000000),
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                      maxLines: 1,
                      cursorColor: const Color(0XFF118611),
                      cursorErrorColor: const Color(0XFF118611),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        filled: true,
                        fillColor: const Color(0XFFFFFFFF),
                        hintText: 'Umur',
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
                      onChanged: (val) => age = val,
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
                          age: age,
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
