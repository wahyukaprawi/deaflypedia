// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deaflypedia_app/screens/profile/dialog_logout.dart';
import 'package:deaflypedia_app/screens/profile/select_avatar.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> with RouteAware {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isFormChanged = false;
  bool _isOverlayVisible = false;
  String? avatarPath;
  int _selectedIndex = 3;
  late OverlayEntry _overlayEntry;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _overlayEntry = _createOverlayEntry();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    hideOverlay();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      if (_selectedIndex == 3 && index != 3) {
        hideOverlay();
      }
      _selectedIndex = index;
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    hideOverlay();
  }

  @override
  void didPushNext() {
    super.didPushNext();
    hideOverlay();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (!mounted) return;
      setState(() {
        userData = doc.data() as Map<String, dynamic>?;
        _nameController.text = userData?['username'] ?? '';
        _ageController.text = userData?['age']?.toString() ?? '';
        avatarPath = userData?['avatar'];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data: $e'),
          ),
        );
      }
    }
  }

  Future<void> _saveAvatarToFirestore(String avatarUrl) async {
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);

      await userDocRef.update({
        'avatar': avatarUrl,
      });

      if (kDebugMode) {
        print("Avatar berhasil disimpan ke Firestore.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Gagal menyimpan avatar ke Firestore: $e");
      }
    }
  }

  Future<void> saveProfileChanges() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'username': _nameController.text,
        'age': int.parse(_ageController.text),
        'avatar': avatarPath,
      });

      setState(() {
        isFormChanged = false;
      });

      _showOverlay();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan!'),
        ),
      );
    }
  }

  Future<void> logOut(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();
      await FirebaseAuth.instance.signOut();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('home_coach_mark_shown_${user?.uid}');
  }

  void _showOverlay() {
    if (!mounted) return;

    if (_isOverlayVisible) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
    _isOverlayVisible = true;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _overlayEntry.mounted) {
        _overlayEntry.remove();
        _isOverlayVisible = false;
      }
    });
  }

  void hideOverlay() {
    if (_isOverlayVisible && _overlayEntry.mounted) {
      _overlayEntry.remove();
      _isOverlayVisible = false;
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 75,
        left: (MediaQuery.of(context).size.width - 225) / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 225,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFC2EABD),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  width: 17,
                  height: 17,
                  image: AssetImage(icCircleCheck),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: const Color(0XFF4CAF50),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Profil berhasil diperbaharui!',
                  style: GoogleFonts.poppins(
                    color: const Color(0XFF000000),
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Column(
      children: [
        ClipOval(
          child: Image.network(
            avatarPath!,
            width: 105,
            height: 105,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              defaultImage,
              width: 105,
              height: 105,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          onTap: () async {
            showSelectAvatar(
              context,
              (selectedAvatarPath) async {
                setState(() {
                  avatarPath = selectedAvatarPath;
                });
                await _saveAvatarToFirestore(selectedAvatarPath);
              },
            );
          },
          child: Text(
            'GANTI AVATAR',
            style: GoogleFonts.poppins(
              color: const Color(0XFF03A9F4),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUserDetails() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Nama',
            style: GoogleFonts.poppins(
              color: const Color(0XFF000000),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            filled: true,
            fillColor: const Color(0XFFFFFFFF),
            hintText: 'Nama',
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
          onChanged: (value) {
            setState(() {
              isFormChanged = _nameController.text.trim() !=
                      userData?['username'] ||
                  _ageController.text.trim() != userData?['age']?.toString();
            });
          },
        ),
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Umur',
            style: GoogleFonts.poppins(
              color: const Color(0XFF000000),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          controller: _ageController,
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
          onChanged: (value) {
            setState(() {
              isFormChanged = _nameController.text.trim() !=
                      userData?['username'] ||
                  _ageController.text.trim() != userData?['age']?.toString();
            });
          },
        ),
      ],
    );
  }

  Widget buildActionButtons() {
    return Column(
      children: [
        InkWell(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          onTap: isFormChanged
              ? () async {
                  await saveProfileChanges();
                }
              : null,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isFormChanged
                  ? const Color(0XFF118611)
                  : const Color(0XFF87C286),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isFormChanged
                        ? const Color(0XFFFFFFFF)
                        : const Color(0XFFFEFEFD),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : userData == null
              ? Center(
                  child: Text(
                    'Data pengguna tidak ditemukan',
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, bottom: 30),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        'Profile',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0XFF000000),
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: InkWell(
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DialogLogout(
                                                logout: () => logOut(context),
                                              );
                                            },
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Icon(
                                            Icons.logout_rounded,
                                            size: 22,
                                            color: Color(0XFFD92D20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                buildProfileHeader(),
                                const SizedBox(height: 50),
                                buildUserDetails(),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    'Deaflypedia v.1.0',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0XFF999999),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                buildActionButtons(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
