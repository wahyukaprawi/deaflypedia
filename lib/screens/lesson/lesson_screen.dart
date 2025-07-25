// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:deaflypedia_app/screens/lesson/dialog_exit_lesson.dart';
import 'package:deaflypedia_app/screens/lesson/lesson_result_screen.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:deaflypedia_app/utils/custom_button_check_off.dart';
import 'package:deaflypedia_app/utils/custom_button_next_quiz.dart';
import 'package:deaflypedia_app/utils/custom_loading.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/custom_button_check.dart';
import '../../utils/custom_button_next_vocabulary.dart';
import '../../utils/custom_progress_bar.dart';

class LessonScreen extends StatefulWidget {
  final String category;
  final String lessonId;
  final String lessonTitle;
  final VoidCallback? onLessonCompleted;

  const LessonScreen({
    super.key,
    required this.category,
    required this.lessonId,
    required this.lessonTitle,
    this.onLessonCompleted,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> contentItems = [];
  Map<int, int> userMatches = {};
  Map<int, int> autoMatches = {};
  Map<int, String> blankAnswers = {};
  int xp = 0;
  int isyarat = 0;
  int currentContentIndex = 0;
  int timeLeft = 30;
  bool isLoading = true;
  bool hasAnswered = false;
  bool isAnswerCorrect = false;
  int? selectedOption;
  int? selectedTopIndex;
  int? selectedBottomIndex;
  String? selectedBlankAnswer;
  String? errorMessage;
  Timer? timer;
  late final TextEditingController _answerController;
  late FocusNode _focusNode;
  late AnimationController _animationControler;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    xp = 0;
    isyarat = 0;
    currentContentIndex = 0;
    isLoading = true;
    hasAnswered = false;
    selectedOption = null;
    errorMessage = null;
    _answerController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
    _animationControler =
        AnimationController(duration: const Duration(seconds: 30), vsync: this);
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationControler)
      ..addListener(() {
        setState(() {});
      });
    startTimer();
    _fetchContent();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _focusNode.dispose();
    _animationControler.dispose();
    super.dispose();
  }

  Future<void> _fetchContent() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.category)
          .collection('lessons')
          .doc(widget.lessonId)
          .get();

      if (!doc.exists) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Pelajaran tidak ditemukan';
        });
        return;
      }

      final data = doc.data();
      if (data == null || !data.containsKey('content')) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Tidak tersedia konten dalam pelajaran ini';
        });
        return;
      }

      final content = data['content'];
      if (content is! List<dynamic>) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Format konten tidak valid';
        });
        return;
      }

      final List<Map<String, dynamic>> items = [];
      int tempIsyaratCount = 0;
      for (var item in content) {
        if (item is Map<String, dynamic>) {
          items.add(item);
          if (item['type'] == 'vocabulary') {
            tempIsyaratCount++;
          }
        }
      }

      final hasQuiz = items.any((item) =>
          item['type'] == 'quiz' ||
          item['type'] == 'gif_quiz' ||
          item['type'] == 'gif_image_quiz' ||
          item['type'] == 'gif_image_matching_quiz' ||
          item['type'] == 'gif_missing_word_quiz' ||
          item['type'] == 'gif_input_word_quiz');

      if (!hasQuiz) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          errorMessage = 'Tidak ada pelajaran ditemukan';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        contentItems = items;
        isyarat = tempIsyaratCount;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Gagal untuk memuat konten ${e.toString()}';
      });
    }
  }

  void _checkAnswer([int? selectedOptionIndex, String? inputAnswer]) {
    if (currentContentIndex >= contentItems.length) return;

    final currentContent = contentItems[currentContentIndex];
    final quizType = currentContent['type'];
    timer?.cancel();
    _animationControler.stop();

    setState(() {
      hasAnswered = true;

      if (quizType == 'gif_image_matching_quiz') {
        try {
          final correctMatches =
              (currentContent['correctMatches'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(int.parse(k), v as int),
          );

          final allUserMatches = {...userMatches, ...autoMatches};
          isAnswerCorrect = _compareMatches(allUserMatches, correctMatches);

          if (isAnswerCorrect) {
            xp += 10;
          }
        } catch (e) {
          debugPrint('Kesalahan dalam mencocokkan kuis $e');
          isAnswerCorrect = false;
        }
        return;
      }

      if (quizType == 'gif_missing_word_quiz') {
        final correctAnswer = currentContent['options']
            [currentContent['correctOptionIndex'] as int];
        isAnswerCorrect = selectedBlankAnswer == correctAnswer;

        if (isAnswerCorrect) {
          xp += 10;
        }
        return;
      }

      if (quizType == 'gif_input_word_quiz') {
        try {
          final correctAnswer = (currentContent['correctAnswer'] ?? '')
              .toString()
              .toLowerCase()
              .trim();
          final userAnswer = (inputAnswer ?? '').toLowerCase().trim();
          isAnswerCorrect = userAnswer == correctAnswer;

          if (isAnswerCorrect) {
            xp += 10;
          }
        } catch (e) {
          debugPrint('Kesalahan dalam kuis input kata $e');
          isAnswerCorrect = false;
        }
        return;
      }

      if (!['quiz', 'gif_quiz', 'gif_image_quiz'].contains(quizType)) return;

      if (selectedOptionIndex == null) {
        isAnswerCorrect = false;
        return;
      }

      selectedOption = selectedOptionIndex;
      try {
        final correctIndex = currentContent['correctOptionIndex'] as int;
        isAnswerCorrect = correctIndex == selectedOptionIndex;
        if (isAnswerCorrect) xp += 10;
      } catch (e) {
        debugPrint('Kesalahan pemeriksaan jawaban $e');
        isAnswerCorrect = false;
      }
    });
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 30;
    _animationControler.reset();
    _animationControler.forward();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        if (!hasAnswered && mounted) {
          _checkAnswer(-1);
        }
      }
    });
  }

  bool _isQuizType(String? type) {
    const quizTypes = {
      'quiz',
      'gif_quiz',
      'gif_image_quiz',
      'gif_image_matching_quiz',
      'gif_missing_word_quiz',
      'gif_input_word_quiz',
    };
    return quizTypes.contains(type);
  }

  void handleTopItemTap(int index) {
    setState(() {
      if (selectedTopIndex == index ||
          userMatches.containsKey(index) ||
          autoMatches.containsKey(index) ||
          autoMatches.containsValue(index) ||
          userMatches.containsValue(index)) {
        final tappedIndex = index;
        final bottomIndex = selectedBottomIndex;

        userMatches.clear();
        autoMatches.clear();
        selectedTopIndex = null;
        selectedBottomIndex = null;

        if (bottomIndex != null) {
          _createMatch(tappedIndex, bottomIndex);
        } else {
          selectedTopIndex = tappedIndex;
        }
      } else if (selectedBottomIndex != null) {
        _createMatch(index, selectedBottomIndex!);
      } else {
        selectedTopIndex = index;
        selectedBottomIndex = null;
      }
    });
  }

  void handleBottomItemTap(int index) {
    setState(() {
      if (selectedBottomIndex == index ||
          userMatches.containsKey(index) ||
          userMatches.containsValue(index) ||
          autoMatches.containsKey(index) ||
          autoMatches.containsValue(index)) {
        final tappedIndex = index;
        final topIndex = selectedTopIndex;

        userMatches.clear();
        autoMatches.clear();
        selectedTopIndex = null;
        selectedBottomIndex = null;

        if (topIndex != null) {
          _createMatch(topIndex, tappedIndex);
        } else {
          selectedBottomIndex = tappedIndex;
        }
      } else if (selectedTopIndex != null) {
        _createMatch(selectedTopIndex!, index);
      } else {
        selectedBottomIndex = index;
        selectedTopIndex = null;
      }
    });
  }

  void _createMatch(int topIndex, int bottomIndex) {
    userMatches[topIndex] = bottomIndex;

    if (topIndex == 0 && bottomIndex == 0 && !userMatches.containsKey(1)) {
      autoMatches[1] = 1;
    } else if (topIndex == 1 &&
        bottomIndex == 1 &&
        !userMatches.containsKey(0)) {
      autoMatches[0] = 0;
    } else if (topIndex == 1 &&
        bottomIndex == 0 &&
        !userMatches.containsKey(0)) {
      autoMatches[0] = 1;
    } else if (topIndex == 0 &&
        bottomIndex == 1 &&
        !userMatches.containsKey(1)) {
      autoMatches[1] = 0;
    }

    selectedTopIndex = null;
    selectedBottomIndex = null;
  }

  CustomBorderData getItemBorder(int index, bool isTopItem) {
    final isSelected =
        isTopItem ? selectedTopIndex == index : selectedBottomIndex == index;

    final isUserMatched = isTopItem
        ? userMatches.containsKey(index)
        : userMatches.containsValue(index);

    final isAutoMatched = isTopItem
        ? autoMatches.containsKey(index) && !userMatches.containsKey(index)
        : autoMatches.containsValue(index) && !userMatches.containsValue(index);

    bool isDotted = isAutoMatched;

    Color color;

    if (hasAnswered) {
      color =
          isAnswerCorrect ? const Color(0xFF4CAF50) : const Color(0xFFEA4C3B);
    } else if (isAutoMatched) {
      color = const Color(0xFF4CAF50);
    } else if (isUserMatched || isSelected) {
      color = const Color(0xFF4CAF50);
    } else {
      color = Colors.transparent;
    }

    return CustomBorderData(color: color, isDotted: isDotted);
  }

  bool _compareMatches(Map<int, int> user, Map<int, int> correct) {
    if (user.length != correct.length) return false;

    for (final entry in user.entries) {
      if (correct[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  Color _getOptionColor(int index) {
    final currentContent = contentItems[currentContentIndex];
    if (currentContent['type'] != 'quiz' &&
            currentContent['type'] != 'gif_quiz' &&
            currentContent['type'] != 'gif_image_quiz' &&
            currentContent['type'] != 'gif_image_matching_quiz' ||
        !hasAnswered) {
      return const Color(0XFFF0F0F0);
    }

    int correctIndex = currentContent['correctOptionIndex'];

    if (index == selectedOption) {
      if (index == correctIndex) {
        return const Color(0XFF4CAF50);
      } else {
        return const Color(0XFFEA4C3B);
      }
    }

    if (index == correctIndex) {
      return Colors.transparent;
    }

    return const Color(0XFFF0F0F0);
  }

  Color _getOptionBorderColor(int index) {
    final currentContent = contentItems[currentContentIndex];
    int correctIndex = currentContent['correctOptionIndex'];

    if (!hasAnswered) {
      return selectedOption == index
          ? const Color(0XFF4CAF50)
          : Colors.transparent;
    } else {
      if (index == correctIndex) {
        return const Color(0XFF4CAF50);
      } else if (selectedOption == index) {
        return const Color(0XFFEA4C3B);
      }
      return Colors.transparent;
    }
  }

  Color _getOptionTextColor(int index) {
    if (!hasAnswered) {
      return const Color(0XFF000000);
    }

    final currentContent = contentItems[currentContentIndex];
    int correctIndex = currentContent['correctOptionIndex'];

    if (index == selectedOption) {
      return const Color(0XFFFFFFFF);
    }

    if (index == correctIndex) {
      return const Color(0XFF000000);
    }

    return const Color(0XFF000000);
  }

  Widget _buildIconCircle(IconData iconData) {
    return Icon(
      size: 18,
      iconData,
      color: const Color(0XFFFFFFFF),
    );
  }

  Widget _buildVocabularyContent(Map<String, dynamic> content) {
    final contentTitle = content['contentTitle'] ?? 'Kosakata';
    final vocabularyText =
        content['vocabularyText'] ?? 'Tidak ada teks kosakata';
    final gifUrl = content['gifUrl'] as String?;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          contentTitle,
          style: GoogleFonts.poppins(
            color: const Color(0XFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        if (gifUrl != null)
          SizedBox(
            width: double.infinity,
            height: 275,
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
                return const Center(
                  child: Text('Gagal memuat Gif'),
                );
              },
            ),
          ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0XFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1,
                color: const Color(0XFFD8D8D8),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              vocabularyText,
              style: GoogleFonts.poppins(
                color: const Color(0XFF000000),
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: CustomButtonNextVocabulary(
            title: 'Berikutnya',
            onTap: () => _goToNextContent(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildQuizContent(Map<String, dynamic> content) {
    final options = List<String>.from(content['options'] ?? []);
    final questionText = content['questionText'] ?? 'Tidak ada teks pertanyaan';
    final gifUrl = content['gifUrl'] as String?;
    final correctOptionIndex = content['correctOptionIndex'] ?? 0;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          questionText,
          style: GoogleFonts.poppins(
            color: const Color(0XFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        if (gifUrl != null)
          SizedBox(
            width: double.infinity,
            height: 275,
            child: Stack(
              children: [
                Positioned.fill(
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
                      return const Center(
                        child: Text('Gagal memuat GIF'),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 35,
                    color: hasAnswered
                        ? const Color(0XFFFFFFFF).withOpacity(0.7)
                        : Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      hasAnswered ? content['options'][correctOptionIndex] : '',
                      style: GoogleFonts.poppins(
                        color: const Color(0XFF000000),
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 30),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return GestureDetector(
            onTap: () {
              if (!hasAnswered) {
                setState(() {
                  selectedOption = index;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: _getOptionColor(index),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _getOptionBorderColor(index),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  option,
                  style: GoogleFonts.poppins(
                    color: _getOptionTextColor(index),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: () {
              if (!hasAnswered) return const Color(0xFFFFFFFF);
              return selectedOption == content['correctOptionIndex']
                  ? const Color(0xFFC2EABD)
                  : const Color(0xFFFEE4E2);
            }(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      selectedOption == content['correctOptionIndex']
                          ? const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleCheck),
                            )
                          : const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleClose),
                            ),
                      const SizedBox(width: 3),
                      Text(
                        selectedOption == content['correctOptionIndex']
                            ? 'Benar!'
                            : 'Salah!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: selectedOption == content['correctOptionIndex']
                              ? const Color(0XFF4CAF50)
                              : const Color(0XFFEA4C3B),
                        ),
                      )
                    ],
                  ),
                ),
              if (hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnswerCorrect
                            ? "Anda menjawab dengan tepat!"
                            : "Jawaban Anda belum tepat!",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: hasAnswered
                    ? CustomButtonNextQuiz(
                        title: currentContentIndex == contentItems.length - 1
                            ? 'Selesai'
                            : 'Berikutnya',
                        onTap: _goToNextContent,
                        color: () {
                          if (!hasAnswered) return const Color(0xFFFFFFFF);
                          return selectedOption == content['correctOptionIndex']
                              ? const Color(0xFF118611)
                              : const Color(0xFFD92D20);
                        }(),
                      )
                    : (selectedOption != null
                        ? CustomButtonCheck(
                            title: 'Cek',
                            onTap: () => _checkAnswer(selectedOption!),
                          )
                        : CustomButtonCheckOff(
                            title: 'Cek',
                            onTap: () {},
                          )),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGifQuizContent(Map<String, dynamic> content) {
    final options = (content['options'] as List).map((item) {
      if (item is Map<String, dynamic>) return item;
      return {'text': item.toString()};
    }).toList();

    final questionText = content['questionText'] ?? 'Tidak ada teks pertanyaan';

    return Column(
      children: [
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'Pilih mana kata ',
              style: GoogleFonts.poppins(
                color: const Color(0XFF000000),
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            TextSpan(
              text: questionText,
              style: GoogleFonts.poppins(
                color: const Color(0XFF000000),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 25,
                mainAxisExtent: 215,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final gifUrl = option['gifUrl'];
                return GestureDetector(
                  onTap: () {
                    if (!hasAnswered) {
                      setState(() => selectedOption = index);
                    }
                  },
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _getOptionBorderColor(index),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (gifUrl != null)
                          Positioned.fill(
                            child: Image.network(
                              gifUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                                return const Center(
                                  child: Text('Gagal memuat GIF'),
                                );
                              },
                            ),
                          ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: !hasAnswered
                                  ? Colors.transparent
                                  : (index == selectedOption &&
                                          selectedOption !=
                                              content['correctOptionIndex'])
                                      ? const Color(0xFFEA4C3B)
                                      : (index == content['correctOptionIndex'])
                                          ? const Color(0xFF4CAF50)
                                          : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: !hasAnswered
                                    ? (selectedOption == index
                                        ? const Color(0XFF4CAF50)
                                        : const Color(0XFFD9D9D9))
                                    : (index == content['correctOptionIndex']
                                        ? const Color(0XFF4CAF50)
                                        : (index == selectedOption &&
                                                selectedOption !=
                                                    content[
                                                        'correctOptionIndex'])
                                            ? const Color(0XFFEA4C3B)
                                            : const Color(0XFFD9D9D9)),
                                width: 2,
                              ),
                            ),
                            child: hasAnswered
                                ? (index == selectedOption &&
                                        selectedOption !=
                                            content['correctOptionIndex'])
                                    ? _buildIconCircle(Icons.close_rounded)
                                    : (index == content['correctOptionIndex'])
                                        ? _buildIconCircle(Icons.check_rounded)
                                        : null
                                : null,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 35,
                            color: hasAnswered
                                ? const Color(0XFFFFFFFF).withOpacity(0.7)
                                : Colors.transparent,
                            alignment: Alignment.center,
                            child: Text(
                              hasAnswered ? option['text'] : '',
                              style: GoogleFonts.poppins(
                                color: const Color(0XFF000000),
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: () {
              if (!hasAnswered) return const Color(0xFFFFFFFF);
              return selectedOption == content['correctOptionIndex']
                  ? const Color(0xFFC2EABD)
                  : const Color(0xFFFEE4E2);
            }(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      selectedOption == content['correctOptionIndex']
                          ? const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleCheck),
                            )
                          : const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleClose),
                            ),
                      const SizedBox(width: 3),
                      Text(
                        selectedOption == content['correctOptionIndex']
                            ? 'Benar!'
                            : 'Salah!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: selectedOption == content['correctOptionIndex']
                              ? const Color(0XFF4CAF50)
                              : const Color(0XFFEA4C3B),
                        ),
                      )
                    ],
                  ),
                ),
              if (hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnswerCorrect
                            ? "Anda menjawab dengan tepat!"
                            : "Jawaban Anda belum tepat!",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: hasAnswered
                    ? CustomButtonNextQuiz(
                        title: currentContentIndex == contentItems.length - 1
                            ? 'Selesai'
                            : 'Berikutnya',
                        onTap: _goToNextContent,
                        color: () {
                          if (!hasAnswered) return const Color(0xFFFFFFFF);
                          return selectedOption == content['correctOptionIndex']
                              ? const Color(0xFF118611)
                              : const Color(0xFFD92D20);
                        }(),
                      )
                    : (selectedOption != null
                        ? CustomButtonCheck(
                            title: 'Cek',
                            onTap: () => _checkAnswer(selectedOption!),
                          )
                        : CustomButtonCheckOff(
                            title: 'Cek',
                            onTap: () {},
                          )),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGifImageQuizContent(Map<String, dynamic> content) {
    final options = (content['options'] as List).map((item) {
      if (item is Map<String, dynamic>) return item;
      return {'text': item.toString()};
    }).toList();
    final questionText = content['questionText'] ?? 'Tidak ada teks pertanyaan';
    final gifUrl = content['gifUrl'] as String?;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          questionText,
          style: GoogleFonts.poppins(
            color: const Color(0XFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        if (gifUrl != null)
          SizedBox(
            width: double.infinity,
            height: 275,
            child: Stack(
              children: [
                Positioned.fill(
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
                      return const Center(
                        child: Text('Gagal memuat GIF'),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 35,
                    color: hasAnswered
                        ? const Color(0XFFFFFFFF).withOpacity(0.7)
                        : Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      hasAnswered
                          ? options[content['correctOptionIndex']]['text']
                          : '',
                      style: GoogleFonts.poppins(
                        color: const Color(0XFF000000),
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 30),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisExtent: 155,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final imageUrl = option['imageUrl'];
                return GestureDetector(
                  onTap: () {
                    if (!hasAnswered) {
                      setState(() => selectedOption = index);
                    }
                  },
                  child: Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _getOptionBorderColor(index),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null)
                          Positioned.fill(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                                return const Center(
                                  child: Text('Gagal memuat GIF'),
                                );
                              },
                            ),
                          ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: !hasAnswered
                                  ? Colors.transparent
                                  : (index == selectedOption &&
                                          selectedOption !=
                                              content['correctOptionIndex'])
                                      ? const Color(0xFFEA4C3B)
                                      : (index == content['correctOptionIndex'])
                                          ? const Color(0xFF4CAF50)
                                          : Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: !hasAnswered
                                    ? (selectedOption == index
                                        ? const Color(0XFF4CAF50)
                                        : const Color(0XFFD9D9D9))
                                    : (index == content['correctOptionIndex']
                                        ? const Color(0XFF4CAF50)
                                        : (index == selectedOption &&
                                                selectedOption !=
                                                    content[
                                                        'correctOptionIndex'])
                                            ? const Color(0XFFEA4C3B)
                                            : const Color(0XFFD9D9D9)),
                                width: 2,
                              ),
                            ),
                            child: hasAnswered
                                ? (index == selectedOption &&
                                        selectedOption !=
                                            content['correctOptionIndex'])
                                    ? _buildIconCircle(Icons.close_rounded)
                                    : (index == content['correctOptionIndex'])
                                        ? _buildIconCircle(Icons.check_rounded)
                                        : null
                                : null,
                          ),
                        ),
                        if (hasAnswered)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 30,
                              color: hasAnswered
                                  ? const Color(0XFFFFFFFF).withOpacity(0.7)
                                  : Colors.transparent,
                              alignment: Alignment.center,
                              child: Text(
                                hasAnswered ? option['text'] : '',
                                style: GoogleFonts.poppins(
                                  color: const Color(0XFF000000),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: () {
              if (!hasAnswered) return const Color(0xFFFFFFFF);
              return selectedOption == content['correctOptionIndex']
                  ? const Color(0xFFC2EABD)
                  : const Color(0xFFFEE4E2);
            }(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      selectedOption == content['correctOptionIndex']
                          ? const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleCheck),
                            )
                          : const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleClose),
                            ),
                      const SizedBox(width: 3),
                      Text(
                        selectedOption == content['correctOptionIndex']
                            ? 'Benar!'
                            : 'Salah!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: selectedOption == content['correctOptionIndex']
                              ? const Color(0XFF4CAF50)
                              : const Color(0XFFEA4C3B),
                        ),
                      )
                    ],
                  ),
                ),
              if (hasAnswered)
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnswerCorrect
                            ? "Anda menjawab dengan tepat!"
                            : "Jawaban Anda belum tepat!",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: hasAnswered
                    ? CustomButtonNextQuiz(
                        title: currentContentIndex == contentItems.length - 1
                            ? 'Selesai'
                            : 'Berikutnya',
                        onTap: _goToNextContent,
                        color: () {
                          if (!hasAnswered) return const Color(0xFFFFFFFF);
                          return selectedOption == content['correctOptionIndex']
                              ? const Color(0xFF118611)
                              : const Color(0xFFD92D20);
                        }(),
                      )
                    : (selectedOption != null
                        ? CustomButtonCheck(
                            title: 'Cek',
                            onTap: () => _checkAnswer(selectedOption!),
                          )
                        : CustomButtonCheckOff(
                            title: 'Cek',
                            onTap: () {},
                          )),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGifImageMatchingQuizContent(Map<String, dynamic> content) {
    final questionText = content['questionText'] ?? 'Tidak ada teks pertanyaan';
    final topItems = List<Map<String, dynamic>>.from(content['topItems'] ?? []);
    final bottomItems =
        List<Map<String, dynamic>>.from(content['bottomItems'] ?? []);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          questionText,
          style: GoogleFonts.poppins(
            color: const Color(0XFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: _buildMatchingGrid(
                  items: topItems,
                  isTop: true,
                  onItemTap: handleTopItemTap,
                  getItemBorder: getItemBorder,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMatchingGrid(
                  items: bottomItems,
                  isTop: false,
                  onItemTap: handleBottomItemTap,
                  getItemBorder: getItemBorder,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: hasAnswered
                ? (isAnswerCorrect
                    ? const Color(0xFFC2EABD)
                    : const Color(0xFFFEE4E2))
                : const Color(0xFFFFFFFF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAnswered) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      isAnswerCorrect
                          ? const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleCheck),
                            )
                          : const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleClose),
                            ),
                      const SizedBox(width: 3),
                      Text(
                        isAnswerCorrect ? 'Benar!' : 'Salah!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isAnswerCorrect
                              ? const Color(0XFF4CAF50)
                              : const Color(0XFFEA4C3B),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnswerCorrect
                            ? "Anda menjawab dengan tepat!"
                            : "Jawaban Anda belum tepat!",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (!isAnswerCorrect)
                        Text(
                          "Cocokkan lagi pasangan yang sesuai",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFFEA4C3B),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: hasAnswered
                    ? CustomButtonNextQuiz(
                        title: currentContentIndex == contentItems.length - 1
                            ? 'Selesai'
                            : 'Berikutnya',
                        onTap: _goToNextContent,
                        color: isAnswerCorrect
                            ? const Color(0xFF118611)
                            : const Color(0xFFD92D20),
                      )
                    : userMatches.isNotEmpty
                        ? CustomButtonCheck(
                            title: 'Cek',
                            onTap: _checkAnswer,
                          )
                        : CustomButtonCheckOff(
                            title: 'Cek',
                            onTap: () {},
                          ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingGrid({
    required List<Map<String, dynamic>> items,
    required bool isTop,
    required Function(int) onItemTap,
    required CustomBorderData Function(int, bool) getItemBorder,
  }) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = isTop ? item['gifUrl'] : item['imageUrl'];

        final borderData = getItemBorder(index, isTop);

        final imageWidget = Container(
          height: 155,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageUrl != null
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
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
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          color: hasAnswered
                              ? const Color(0XFFFFFFFF).withOpacity(0.7)
                              : Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            hasAnswered ? item['text'] ?? '' : '',
                            style: GoogleFonts.poppins(
                              color: const Color(0XFF000000),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        );

        final Widget borderedChild = borderData.isDotted
            ? DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(15),
                color: borderData.color,
                strokeWidth: 2,
                dashPattern: const [6, 4],
                padding: EdgeInsets.zero,
                child: imageWidget,
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: borderData.color,
                    width: 2,
                  ),
                ),
                child: imageWidget,
              );

        return GestureDetector(
          onTap: () => onItemTap(index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: borderedChild,
          ),
        );
      },
    );
  }

  Widget _buildMissingWordQuizContent(Map<String, dynamic> content) {
    final questionText = content['questionText'] ?? 'Tidak ada teks pertanyaan';
    final fullPhrase =
        content['fullPhrase'] ?? 'Tidak ada teks kalimat lengkap';
    final options = List<String>.from(content['options'] ?? []);
    final gifUrl = content['gifUrl'] as String?;
    final correctOptionIndex = content['correctOptionIndex'] ?? 0;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          questionText,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: const Color(0XFF000000),
          ),
        ),
        const SizedBox(height: 20),
        if (gifUrl != null)
          SizedBox(
            width: double.infinity,
            height: 275,
            child: Stack(
              children: [
                Positioned.fill(
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
                      return const Center(child: Text('Gagal memuat GIF'));
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 35,
                    color: hasAnswered
                        ? const Color(0XFFFFFFFF).withOpacity(0.7)
                        : Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      hasAnswered ? content['options'][correctOptionIndex] : '',
                      style: GoogleFonts.poppins(
                        color: const Color(0XFF000000),
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: RichText(
              key: ValueKey(selectedBlankAnswer),
              textAlign: TextAlign.center,
              text: TextSpan(
                children: _buildPhraseWithChip(fullPhrase),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: options.map<Widget>((option) {
              final isSelected = selectedBlankAnswer == option;

              return isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: 1.5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 9.4),
                        decoration: BoxDecoration(
                          color: const Color(0XFFEAEAEA),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    )
                  : ChoiceChip(
                      padding: EdgeInsets.zero,
                      label: Text(
                        option,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: const Color(0XFF000000),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      selected: selectedBlankAnswer == option,
                      onSelected: (selected) {
                        setState(() {
                          selectedBlankAnswer = selected ? option : null;
                        });
                      },
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 5,
                      ),
                      selectedColor: const Color(0XFFFFFFFF),
                      backgroundColor: const Color(0XFFFFFFFF),
                      side: BorderSide(
                        color: hasAnswered
                            ? (!isAnswerCorrect &&
                                    option ==
                                        content['options'][correctOptionIndex]
                                ? const Color(0XFF4CAF50)
                                : const Color(0xFFDCDCDC))
                            : const Color(0xFFDCDCDC),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0XFF000000),
                        fontWeight: FontWeight.w300,
                      ),
                    );
            }).toList(),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: hasAnswered
                ? (isAnswerCorrect
                    ? const Color(0xFFC2EABD)
                    : const Color(0xFFFEE4E2))
                : const Color(0xFFFFFFFF),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAnswered) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Row(
                    children: [
                      isAnswerCorrect
                          ? const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleCheck),
                            )
                          : const Image(
                              width: 16,
                              height: 16,
                              image: AssetImage(icCircleClose),
                            ),
                      const SizedBox(width: 3),
                      Text(
                        isAnswerCorrect ? 'Benar!' : 'Salah!',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: isAnswerCorrect
                              ? const Color(0XFF4CAF50)
                              : const Color(0XFFEA4C3B),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAnswerCorrect
                            ? "Anda menjawab dengan tepat!"
                            : "Jawaban Anda belum tepat!",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: hasAnswered
                    ? CustomButtonNextQuiz(
                        title: currentContentIndex == contentItems.length - 1
                            ? 'Selesai'
                            : 'Berikutnya',
                        onTap: _goToNextContent,
                        color: isAnswerCorrect
                            ? const Color(0xFF118611)
                            : const Color(0xFFD92D20),
                      )
                    : (selectedBlankAnswer != null
                        ? CustomButtonCheck(
                            title: 'Cek',
                            onTap: () => _checkAnswer(),
                          )
                        : CustomButtonCheckOff(
                            title: 'Cek',
                            onTap: () {},
                          )),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  List<InlineSpan> _buildPhraseWithChip(String phrase) {
    final parts = phrase.split('_____');
    final spans = <InlineSpan>[];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w300,
          color: const Color(0xFF000000),
        ),
      ));

      if (i != parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: selectedBlankAnswer != null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBlankAnswer = null;
                        });
                      },
                      child: Container(
                        key: ValueKey(selectedBlankAnswer),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: hasAnswered
                              ? (isAnswerCorrect
                                  ? const Color(0XFF4CAF50)
                                  : const Color(0XFFEA4C3B))
                              : const Color(0XFFFFFFFF),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: hasAnswered
                                ? (isAnswerCorrect
                                    ? const Color(0XFF4CAF50)
                                    : const Color(0XFFEA4C3B))
                                : const Color(0xFFDCDCDC),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          selectedBlankAnswer!,
                          style: GoogleFonts.poppins(
                            color: hasAnswered
                                ? const Color(0XFFFFFFFF)
                                : const Color(0XFF000000),
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      key: const ValueKey('placeholder'),
                      height: 2,
                      width: 60,
                      margin: const EdgeInsets.only(top: 20, right: 5, left: 5),
                      color: const Color(0xFFE7E7E7),
                    ),
            ),
          ),
        );
      }
    }
    return spans;
  }

  Widget _buildInputQuizContent(Map<String, dynamic> content) {
    final questionText = content['questionText'] ?? 'Tidak ada teks pertanyaan';
    final gifUrl = content['gifUrl'] as String?;

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  questionText,
                  style: GoogleFonts.poppins(
                    color: const Color(0XFF000000),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                if (gifUrl != null)
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 275,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                gifUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4CAF50)),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text('Gagal memuat GIF'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: double.infinity,
                          height: 35,
                          color: hasAnswered
                              ? const Color(0XFFFFFFFF).withOpacity(0.7)
                              : Colors.transparent,
                          alignment: Alignment.center,
                          child: Text(
                            hasAnswered ? content['correctAnswer'] : '',
                            style: GoogleFonts.poppins(
                              color: const Color(0XFF000000),
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0XFFDADCD9),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_answerController.text.isNotEmpty || hasAnswered)
                          CustomPaint(
                            painter: _TextBackgroundPainter(
                              text: _answerController.text,
                              backgroundColor: hasAnswered
                                  ? (isAnswerCorrect
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFEA4C3B))
                                  : const Color(0xFFF0F0F0),
                              controller: _answerController,
                              textStyle: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        if (_answerController.text.isEmpty &&
                            !hasAnswered &&
                            !_focusNode.hasFocus)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 110,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        TextFormField(
                          controller: _answerController,
                          focusNode: _focusNode,
                          enabled: !hasAnswered,
                          keyboardType: TextInputType.text,
                          cursorColor: const Color(0XFF118611),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: hasAnswered
                                ? const Color(0xFFFFFFFF)
                                : _answerController.text.isNotEmpty
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF818682),
                            fontWeight: FontWeight.w400,
                            backgroundColor: Colors.transparent,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: _focusNode.hasFocus ||
                                    _answerController.text.isNotEmpty
                                ? ''
                                : 'ketik disini',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: const Color(0XFF818682),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                          onChanged: (text) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    color: hasAnswered
                        ? (isAnswerCorrect
                            ? const Color(0xFFC2EABD)
                            : const Color(0xFFFEE4E2))
                        : const Color(0xFFFFFFFF),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasAnswered) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Row(
                            children: [
                              isAnswerCorrect
                                  ? const Image(
                                      width: 16,
                                      height: 16,
                                      image: AssetImage(icCircleCheck),
                                    )
                                  : const Image(
                                      width: 16,
                                      height: 16,
                                      image: AssetImage(icCircleClose),
                                    ),
                              const SizedBox(width: 3),
                              Text(
                                isAnswerCorrect ? 'Benar!' : 'Salah!',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: isAnswerCorrect
                                      ? const Color(0XFF4CAF50)
                                      : const Color(0XFFEA4C3B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAnswerCorrect
                                    ? "Anda menjawab dengan tepat!"
                                    : "Jawaban Anda belum tepat!",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF000000),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: hasAnswered
                            ? CustomButtonNextQuiz(
                                title: currentContentIndex ==
                                        contentItems.length - 1
                                    ? 'Selesai'
                                    : 'Berikutnya',
                                onTap: _goToNextContent,
                                color: isAnswerCorrect
                                    ? const Color(0xFF118611)
                                    : const Color(0xFFD92D20),
                              )
                            : (_answerController.text.isNotEmpty
                                ? CustomButtonCheck(
                                    title: 'Cek',
                                    onTap: () => _checkAnswer(
                                        null, _answerController.text),
                                  )
                                : CustomButtonCheckOff(
                                    title: 'Cek', onTap: () {})),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: GoogleFonts.poppins(
            color: const Color(0XFF000000),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    if (contentItems.isEmpty) {
      return const Center(child: Text('Tidak ada konten tersedia'));
    }

    final content = contentItems[currentContentIndex];
    final type = content['type'] ?? 'quiz';

    if (type == 'quiz') {
      return _buildQuizContent(content);
    } else if (type == 'gif_quiz') {
      return _buildGifQuizContent(content);
    } else if (type == 'gif_image_quiz') {
      return _buildGifImageQuizContent(content);
    } else if (type == 'gif_image_matching_quiz') {
      return _buildGifImageMatchingQuizContent(content);
    } else if (type == 'gif_missing_word_quiz') {
      return _buildMissingWordQuizContent(content);
    } else if (type == 'gif_input_word_quiz') {
      return _buildInputQuizContent(content);
    } else {
      return _buildVocabularyContent(content);
    }
  }

  Future<void> _updateUserXP(int earnedXP) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentXP = (snapshot.data()?['xp'] ?? 0) as int;
      transaction.update(userRef, {'xp': currentXP + earnedXP});
    });
  }

  Future<void> _updateUserStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data();

      final lastDateTimestamp = data?['lastActivityDate'];
      final lastDate = lastDateTimestamp != null
          ? (lastDateTimestamp as Timestamp).toDate()
          : null;

      final streak = (data?['streak'] ?? 0) as int;

      DateTime? lastDay = lastDate != null
          ? DateTime(lastDate.year, lastDate.month, lastDate.day)
          : null;

      int newStreak = 1;

      if (lastDay != null) {
        final difference = today.difference(lastDay).inDays;

        if (difference == 1) {
          newStreak = streak + 1;
        } else if (difference == 0) {
          newStreak = streak;
        } else {
          newStreak = 1;
        }
      }

      transaction.update(userRef, {
        'streak': newStreak,
        'lastActivityDate': Timestamp.fromDate(today),
      });
    });
  }

  Future<void> _updateUserIsyarat(int earnedIsyarat) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentIsyarat = (snapshot.data()?['isyarat'] ?? 0) as int;
      transaction.update(userRef, {
        'isyarat': currentIsyarat + earnedIsyarat,
      });
    });
  }

  Future<void> _completeLesson() async {
    _showLoadingDialog();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final validQuizTypes = {
        'quiz',
        'gif_quiz',
        'gif_image_quiz',
        'gif_image_matching_quiz',
        'gif_missing_word_quiz',
        'gif_input_word_quiz',
      };

      int totalQuestions =
          contentItems.where((c) => validQuizTypes.contains(c['type'])).length;

      int percentage =
          totalQuestions == 0 ? 0 : ((xp ~/ 10) / totalQuestions * 100).round();

      final batch = FirebaseFirestore.instance.batch();

      final currentLessonRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('progress')
          .doc(widget.category)
          .collection('lessons')
          .doc(widget.lessonId);

      final currentLessonSnap = await currentLessonRef.get();
      final alreadyCompleted = currentLessonSnap.exists &&
          (currentLessonSnap.data()?['isCompleted'] == true);

      batch.set(
        currentLessonRef,
        {
          'isCompleted': true,
          'score': percentage,
          'lastAccessed': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!alreadyCompleted) {
        await _updateUserIsyarat(isyarat);

        final currentNumber = int.tryParse(widget.lessonId.split('_').last);
        if (currentNumber != null) {
          final nextLessonId = 'lesson_${currentNumber + 1}';
          final nextLessonDoc = await FirebaseFirestore.instance
              .collection('categories')
              .doc(widget.category)
              .collection('lessons')
              .doc(nextLessonId)
              .get();

          if (nextLessonDoc.exists) {
            final nextLessonRef = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('progress')
                .doc(widget.category)
                .collection('lessons')
                .doc(nextLessonId);

            batch.set(
              nextLessonRef,
              {
                'isLocked': false,
                'isCompleted': false,
                'score': 0,
              },
              SetOptions(merge: true),
            );
          }
        }
      }

      await batch.commit();
      await _updateUserXP(xp);
      await _updateUserStreak();

      _hideLoadingDialog();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonResultScreen(
            xp: xp,
            totalQuestions: totalQuestions,
            category: widget.category,
            lessonId: widget.lessonId,
            lessonTitle: widget.lessonTitle,
          ),
        ),
      );
    } catch (e) {
      _hideLoadingDialog();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan progress: ${e.toString()}')),
      );
    }
  }

  void resetQuestionState() {
    hasAnswered = false;
    isAnswerCorrect = false;
    selectedOption = null;
    selectedTopIndex = null;
    selectedBottomIndex = null;
    selectedBlankAnswer = null;
    userMatches.clear();
    autoMatches.clear();
    _answerController.clear();
    _animationControler.reset();
  }

  void _goToNextContent() {
    if (currentContentIndex < contentItems.length - 1) {
      setState(() {
        currentContentIndex++;
        resetQuestionState();
      });
      final nextType = contentItems[currentContentIndex]['type'];
      final isQuiz = _isQuizType(nextType);

      if (isQuiz) {
        startTimer();
      } else {
        timer?.cancel();
        _animationControler.reset();
      }
    } else {
      _completeLesson();
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CustomLoading());
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalContentCount = contentItems.length;
    final progressValue = totalContentCount > 0
        ? (currentContentIndex + 1) / totalContentCount
        : 0;
    final currentType = contentItems.isNotEmpty
        ? contentItems[currentContentIndex]['type']
        : null;

    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 17),
            child: Row(
              children: [
                InkWell(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const DialogExitLesson();
                      },
                    );
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 32,
                    color: Color(0XFF118611),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomProgressBar(
                    value: progressValue,
                  ),
                ),
                const SizedBox(width: 13),
                if (_isQuizType(currentType))
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: timeLeft > 10
                              ? const Color(0XFFC2EABD)
                              : const Color(0XFFFEE4E2),
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          value: _animation.value,
                          backgroundColor: const Color(0XFFF0F0F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            timeLeft > 10
                                ? const Color(0XFF118611)
                                : const Color(0XFFD92D20),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      Text(
                        timeLeft.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: timeLeft > 10
                              ? const Color(0XFF118611)
                              : const Color(0XFFD92D20),
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(
                    width: 40,
                    height: 40,
                  ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }
}

class CustomBorderData {
  final Color color;
  final bool isDotted;

  const CustomBorderData({
    required this.color,
    this.isDotted = false,
  });
}

class _TextBackgroundPainter extends CustomPainter {
  final String text;
  final Color backgroundColor;
  final TextEditingController controller;
  final TextStyle textStyle;

  _TextBackgroundPainter({
    required this.text,
    required this.backgroundColor,
    required this.controller,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final backgroundWidth = textPainter.width + 22;
    final backgroundHeight = textPainter.height + 8;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final backgroundRect = Rect.fromCenter(
      center: Offset(centerX - 1.5, centerY),
      width: backgroundWidth,
      height: backgroundHeight,
    );

    const radius = Radius.circular(3);
    final rrect = RRect.fromRectAndRadius(backgroundRect, radius);

    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
