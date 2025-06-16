// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deaflypedia_app/screens/lesson/result_feedback.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/home_screen.dart';
import 'lesson_screen.dart';

class LessonResultScreen extends StatefulWidget {
  final int xp;
  final int totalQuestions;
  final String category;
  final String lessonId;
  final String lessonTitle;
  final VoidCallback? onNextLesson;

  const LessonResultScreen({
    super.key,
    required this.xp,
    required this.totalQuestions,
    required this.category,
    required this.lessonId,
    required this.lessonTitle,
    this.onNextLesson,
  });

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen> {
  bool isLoading = true;
  late int percentage;
  late ResultFeedback feedback;
  bool isLastLesson = false;

  int _correctPercentage(int xp, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    int correctAnswers = xp ~/ 10;
    double percentage = (correctAnswers / totalQuestions) * 100;
    return percentage.round().clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final lessons = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.category)
        .collection('lessons')
        .get();

    setState(() {
      percentage = _correctPercentage(widget.xp, widget.totalQuestions);
      feedback = getResultFeedback(percentage);
      isLastLesson = widget.lessonId == lessons.docs.last.id;
      isLoading = false;
    });
  }

  Future<void> _goToNextLesson() async {
    final currentNumber = int.tryParse(widget.lessonId.split('_').last);
    if (currentNumber == null) return;

    final nextLessonId = 'lesson_${currentNumber + 1}';

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nextProgressRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(widget.category)
        .collection('lessons')
        .doc(nextLessonId);

    final snapshot = await nextProgressRef.get();

    if (!mounted) return;

    if (snapshot.exists && !(snapshot.data()?['isLocked'] ?? true)) {
      final nextLessonDoc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.category)
          .collection('lessons')
          .doc(nextLessonId)
          .get();

      if (!mounted) return;

      if (nextLessonDoc.exists) {
        final nextLessonTitle =
            nextLessonDoc['lessonTitle'] ?? 'Pelajaran ${currentNumber + 1}';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LessonScreen(
              category: widget.category,
              lessonId: nextLessonId,
              lessonTitle: nextLessonTitle,
              onLessonCompleted: widget.onNextLesson,
            ),
          ),
        );
        return;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Pelajaran selanjutnya belum tersedia atau masih terkunci'),
      ),
    );
  }

  void _repeatCurrentLesson() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          category: widget.category,
          lessonId: widget.lessonId,
          lessonTitle: widget.lessonTitle,
          onLessonCompleted: widget.onNextLesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF118611),
          ),
        ),
      );
    }

    final Color percentageColor =
        percentage >= 80 ? const Color(0xFF4CAF50) : const Color(0xFFEA4C3B);

    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.poppins(
                        color: percentageColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      feedback.title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF000000),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      feedback.subtitle,
                      style: GoogleFonts.poppins(
                        color: const Color(0XFF74737A),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Image(
                      width: 250,
                      image: AssetImage(feedback.imageAsset),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool isPassed = percentage >= 80;

    if (isLastLesson) {
      if (isPassed) {
        return Column(
          children: [
            InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: const Color(0XFF118611),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              onTap: _repeatCurrentLesson,
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'Ulangi',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0XFF000000),
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              onTap: _repeatCurrentLesson,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: const Color(0XFFD92D20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Ulangi',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  'Kembali ke Beranda',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0XFF000000),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    } else {
      return Column(
        children: [
          InkWell(
            onTap: isPassed ? _goToNextLesson : _repeatCurrentLesson,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: isPassed
                    ? const Color(0XFF118611)
                    : const Color(0XFFD92D20),
              ),
              alignment: Alignment.center,
              child: Text(
                isPassed ? 'Lanjutkan belajar' : 'Ulangi',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0XFFFFFFFF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: isPassed ? _repeatCurrentLesson : _goToNextLesson,
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                isPassed ? 'Ulangi' : 'Lanjutkan belajar',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0XFF000000),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
