// ignore_for_file: use_build_context_synchronously

import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:deaflypedia_app/utils/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/introduction_screen.dart';

class DialogLogout extends StatelessWidget {
  final Future<void> Function() logout;
  const DialogLogout({super.key, required this.logout});

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomLoading()),
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        height: 355,
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
              image: AssetImage(icCircleLogout),
            ),
            const SizedBox(height: 20),
            Text(
              'Logout dari Deaflypedia',
              style: GoogleFonts.poppins(
                color: const Color(0XFF000000),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Dengan keluar dari aplikasi, akun Anda\nakan dihapus!',
              style: GoogleFonts.poppins(
                color: const Color(0XFF646960),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Divider(thickness: 1, color: Color(0XFFEBEBEB)),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: () async {
                  _showLoadingDialog(context);
                  await logout();
                  _hideLoadingDialog(context);
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IntroductionScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0XFFFEE4E2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Logout aplikasi',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0XFFD92D20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0XFFFFFFFF),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0XFFEBEBEB)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Kembali',
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
