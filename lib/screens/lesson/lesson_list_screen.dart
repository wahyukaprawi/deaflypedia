import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deaflypedia_app/screens/lesson/lesson_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/assert_image.dart';

class Lesson {
  final String id;
  final String lessonTitle;
  final String lessonDescription;
  final bool isLocked;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.lessonTitle,
    required this.lessonDescription,
    required this.isLocked,
    required this.isCompleted,
  });

  factory Lesson.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lesson(
      id: doc.id,
      lessonTitle: data['lessonTitle'] ?? 'Pelajaran',
      lessonDescription: data['lessonDescription'] ?? 'Deskripsi',
      isLocked: data['isLocked'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
    );
  }
}

class LessonList extends StatelessWidget {
  final List<Lesson> lessons;
  final String category;

  const LessonList({super.key, required this.lessons, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(lessons.length, (index) {
        final lesson = lessons[index];
        final isFirst = index == 0;
        final isLast = index == lessons.length - 1;
        final isCompleted = lesson.isCompleted;
        final isPrevCompleted =
            index > 0 ? lessons[index - 1].isCompleted : false;
        return Stack(
          children: [
            Positioned(
              right: 42,
              top: isFirst ? 50 : 0,
              bottom: isLast ? 50 : 0,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 13,
                      color: isPrevCompleted
                          ? const Color(0XFF7EB17E)
                          : const Color(0XFFE9E9E9),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 13,
                      color: isCompleted
                          ? const Color(0XFF7EB17E)
                          : const Color(0XFFE9E9E9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.5),
              child: Row(
                children: [
                  Expanded(
                    child: LessonCard(
                      lesson: lesson,
                      category: category,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class LessonListScreen extends StatefulWidget {
  final String category;
  const LessonListScreen({super.key, required this.category});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  Stream<List<Lesson>> _lessonStream() {
    final user = FirebaseAuth.instance.currentUser!;
    final category = widget.category;

    final lessonsStream = FirebaseFirestore.instance
        .collection('categories')
        .doc(category)
        .collection('lessons')
        .snapshots();

    final progressStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(category)
        .collection('lessons')
        .snapshots();

    return Rx.combineLatest2<QuerySnapshot, QuerySnapshot, List<Lesson>>(
      lessonsStream,
      progressStream,
      (lessonsSnapshot, progressSnapshot) {
        final progressMap = {
          for (var doc in progressSnapshot.docs)
            doc.id: doc.data() as Map<String, dynamic>
        };

        List<Lesson> lessons = [];

        for (var doc in lessonsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final lessonId = doc.id;
          final progressData = progressMap[lessonId] ?? <String, dynamic>{};
          final lessonNumber = int.tryParse(lessonId.split('_').last) ?? 0;
          final prevLessonId = 'lesson_${lessonNumber - 1}';

          final prevProgress = progressMap[prevLessonId];
          final prevIsCompleted = (prevProgress is Map<String, dynamic>)
              ? (prevProgress['isCompleted'] as bool? ?? false)
              : false;

          lessons.add(
            Lesson(
              id: lessonId,
              lessonTitle: data['lessonTitle'] ?? 'Pelajaran',
              lessonDescription: data['lessonDescription'] ?? 'Deskripsi',
              isLocked: lessonId != 'lesson_1' && !prevIsCompleted,
              isCompleted: (progressData['isCompleted'] as bool?) ?? false,
            ),
          );
        }
        return lessons;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: StreamBuilder<List<Lesson>>(
        stream: _lessonStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan ${snapshot.error}'));
          }

          final lessons = snapshot.data ?? [];

          return LessonContent(
            lessons: lessons,
            category: widget.category,
          );
        },
      ),
    );
  }
}

class LessonContent extends StatelessWidget {
  final List<Lesson> lessons;
  final String category;

  const LessonContent(
      {super.key, required this.lessons, required this.category});
  
   String capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgLesson),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 26,
                      color: Color(0XFFFFFFFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kosakata\n ${capitalize(category)}',
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
                padding: const EdgeInsets.only(
                    left: 25, right: 25, bottom: 25, top: 12.5),
                decoration: const BoxDecoration(
                  color: Color(0XFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: LessonList(lessons: lessons, category: category),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final String category;

  const LessonCard({super.key, required this.lesson, required this.category});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;
    double iconSize;

    if (lesson.isCompleted) {
      iconData = Icons.check;
      iconColor = const Color(0XFF4CAF50);
      iconSize = 30;
    } else if (lesson.isLocked) {
      iconData = Icons.lock;
      iconColor = const Color(0XFFA1A1A1);
      iconSize = 27.5;
    } else {
      iconData = Icons.play_arrow_rounded;
      iconColor = const Color(0XFFA1A1A1);
      iconSize = 40;
    }

    return GestureDetector(
      onTap: () {
        if (lesson.isLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pelajaran masih terkunci'),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(
                category: category,
                lessonId: lesson.id,
                lessonTitle: lesson.lessonTitle,
                onLessonCompleted: () {},
              ),
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 109,
        decoration: BoxDecoration(
          color: const Color(0XFFFFFFFF),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.lessonTitle,
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF000000),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    lesson.lessonDescription,
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF74737A),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: lesson.isLocked
                      ? const Color(0XFFE9E9E9)
                      : lesson.isCompleted
                          ? const Color(0xFFC2EABD)
                          : const Color(0XFFE9E9E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: iconSize, color: iconColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
