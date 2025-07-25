import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deaflypedia_app/screens/alphabet/alphabet_screen.dart';
import 'package:deaflypedia_app/screens/lesson/lesson_list_screen.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../main.dart';
import '../../utils/custom_coach_mark.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final GlobalKey<ProfileScreenState> _profileScreenKey = GlobalKey();
  String get _coachMarkShownKey =>
      'coach_mark_shown_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  List<Map<String, dynamic>> categories = [];
  List<TargetFocus> targets = [];
  TutorialCoachMark? tutorialCoachMark;
  String? username;
  int? xp;
  int? streak;
  int? isyarat;
  bool isLoading = true;
  bool canClaimBonus = true;
  bool isDataReady = false;
  bool _isOverlayVisible = false;
  int _selectedIndex = 0;
  late PageController _pageController;
  late OverlayEntry _overlayEntry;
  late SharedPreferences _prefs;

  GlobalKey statsKey = GlobalKey();
  GlobalKey xpKey = GlobalKey();
  GlobalKey streakKey = GlobalKey();
  GlobalKey isyaratKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _overlayEntry = _createOverlayEntry();
    _initializeAppData();
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
    _hideOverlay();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeAppData() async {
    _prefs = await SharedPreferences.getInstance();
    await initializeData();

    if (mounted) {
      setState(() {
        isDataReady = true;
      });
      _checkAndShowCoachMark();
    }
  }

  Future<void> _checkAndShowCoachMark() async {
    final hasShownCoachMark = _prefs.getBool(_coachMarkShownKey) ?? false;

    if (!hasShownCoachMark && mounted) {
      await Future.delayed(const Duration(seconds: 3));

      if (mounted && statsKey.currentContext != null) {
        await _prefs.setBool(_coachMarkShownKey, true);
        _showTutorialCoachMark();
      }
    }
  }

  void _showTutorialCoachMark() {
    _initTarget();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      paddingFocus: 0,
      pulseAnimationDuration: const Duration(milliseconds: 600),
      hideSkip: true,
    )..show(context: context);
  }

  void _initTarget() {
    targets.add(
      TargetFocus(
        identify: "stats-key",
        keyTarget: statsKey,
        shape: ShapeLightFocus.RRect,
        radius: 7,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CustomCoachMark(
                title: 'Statistik Pengguna',
                desc:
                    'Di sini kamu bisa melihat seberapa jauh kamu sudah belajar. Ada XP, Streak, dan jumlah Isyarat yang sudah kamu pelajari. Semangat terus ya!',
                icImage: const AssetImage(icStatistik),
                skip: 'Lewati',
                next: 'Lanjut',
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "xp-key",
        keyTarget: xpKey,
        shape: ShapeLightFocus.RRect,
        radius: 7,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CustomCoachMark(
                title: 'XP',
                desc:
                    'XP adalah poin yang kamu dapatkan setiap kali belajar atau menyelesaikan latihan. Makin banyak belajar, makin banyak XP!',
                icImage: const AssetImage(icXP),
                skip: 'Lewati',
                next: 'Lanjut',
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "streak-key",
        keyTarget: streakKey,
        shape: ShapeLightFocus.RRect,
        radius: 7,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CustomCoachMark(
                title: 'Streak',
                desc:
                    'Streak adalah jumlah hari kamu belajar tanpa berhenti. Belajar setiap hari akan membuat streak-mu bertambah.',
                icImage: const AssetImage(icStreak),
                skip: 'Lewati',
                next: 'Lanjut',
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "isyarat-key",
        keyTarget: isyaratKey,
        shape: ShapeLightFocus.RRect,
        radius: 7,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return CustomCoachMark(
                title: 'Isyarat',
                desc:
                    'Ini adalah jumlah isyarat atau kata yang sudah kamu pelajari. Yuk, tambah terus supaya kamu makin hebat!',
                icImage: const AssetImage(icIsyarat),
                skip: 'Lewati',
                next: 'Selesai',
                onSkip: () => controller.skip(),
                onNext: () => controller.next(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> initializeData() async {
    try {
      await Future.wait([fetchUserData()]);
    } catch (e) {
      debugPrint('Gagal inisialisasi: $e');
    } finally {
      if (mounted) {
        setState(() {
          isDataReady = true;
        });
      }
    }
  }

  Stream<DocumentSnapshot> getUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      setState(() {
        username = data['username'] ?? 'guest';
        xp = data['xp'] ?? 0;
        streak = data['streak'] ?? 0;
        isyarat = data['isyarat'] ?? 0;
      });
    }

    final categoriesSnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('order')
        .get();

    setState(() {
      categories = categoriesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'iconLockUrl': data['iconLockUrl'] ?? '',
          'iconUnlockUrl': data['iconUnlockUrl'] ?? '',
        };
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == 0 && index != 0) {
        _hideOverlay();
      }

      if (_selectedIndex == 3 && index != 3) {
        _profileScreenKey.currentState?.hideOverlay();
      }

      _selectedIndex = index;
    });
  }

  Color _getIconColor(int index) {
    return _selectedIndex == index
        ? const Color(0XFF118611)
        : const Color(0XFF999999);
  }

  String capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> claimDailyXP() async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user!.uid);

    final snapshot = await userRef.get();
    final data = snapshot.data();

    if (data == null) return;

    final now = DateTime.now();
    final lastClaim = (data['lastClaim'] as Timestamp?)?.toDate();

    final todayReset = DateTime(now.year, now.month, now.day, 7);
    bool alreadyClaimed = false;

    if (now.isBefore(todayReset)) {
      final yesterdayReset = todayReset.subtract(const Duration(days: 1));
      alreadyClaimed = lastClaim != null && lastClaim.isAfter(yesterdayReset);
    } else {
      alreadyClaimed = lastClaim != null && lastClaim.isAfter(todayReset);
    }

    if (!alreadyClaimed) {
      await userRef.update({
        'xp': (data['xp'] ?? 0) + 15,
        'lastClaim': now,
      });
      await fetchUserData();

      setState(() {
        canClaimBonus = false;
      });
      _showOverlay();
    }
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

  void _hideOverlay() {
    if (_isOverlayVisible && _overlayEntry.mounted) {
      _overlayEntry.remove();
      _isOverlayVisible = false;
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: 75,
        left: (MediaQuery.of(context).size.width - 254) / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 254,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFC2EABD),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  width: 20,
                  height: 20,
                  image: AssetImage(icParty),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 1,
                  height: 18,
                  color: const Color(0XFF4CAF50),
                ),
                const SizedBox(width: 5),
                Text(
                  'Yeay! Kamu dapat 15 XP hari ini!',
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

  Widget _buildCategoryGrid() {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pelajaran yang tersedia',
          style: GoogleFonts.poppins(
            color: const Color(0XFF000000),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Pengguna belum masuk'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 40),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  );
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;

                final name = data?['username'] ?? 'User';
                final xp = data?['xp'] ?? 0;
                final streak = data?['streak'] ?? 0;
                final isyarat = data?['isyarat'] ?? 0;
                final lastClaim = (data?['lastClaim'] as Timestamp?)?.toDate();

                final now = DateTime.now();
                final todayReset = DateTime(now.year, now.month, now.day, 7);
                bool alreadyClaimed = false;

                if (now.isBefore(todayReset)) {
                  final yesterdayReset =
                      todayReset.subtract(const Duration(days: 1));
                  alreadyClaimed =
                      lastClaim != null && lastClaim.isAfter(yesterdayReset);
                } else {
                  alreadyClaimed =
                      lastClaim != null && lastClaim.isAfter(todayReset);
                }

                canClaimBonus = !alreadyClaimed;

                return Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Halo, ${capitalize(name)}',
                        style: GoogleFonts.poppins(
                          color: const Color(0XFF000000),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      key: statsKey,
                      width: double.infinity,
                      height: 113,
                      decoration: BoxDecoration(
                        color: const Color(0XFFFFFFFF),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: const Color(0XFFEEEEEE),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 232, 236, 243),
                            blurRadius: 5,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              key: xpKey,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  width: 26,
                                  height: 26,
                                  image: AssetImage(icXP),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'XP\n',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF000000),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$xp',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF000000),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              key: streakKey,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  width: 26,
                                  height: 26,
                                  image: AssetImage(icStreak),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Streak\n',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF000000),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$streak',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF000000),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              key: isyaratKey,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  width: 26,
                                  height: 26,
                                  image: AssetImage(icIsyarat),
                                ),
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Isyarat\n',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF000000),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$isyarat',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF000000),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 73,
                      decoration: BoxDecoration(
                        color: const Color(0XFFFFFFFF),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: const Color(0XFFEEEEEE),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 232, 236, 243),
                            blurRadius: 5,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 10),
                              child: Row(
                                children: [
                                  const Image(
                                    width: 19,
                                    height: 17,
                                    image: AssetImage(icGift),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bonus harian',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0XFF000000),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      canClaimBonus
                                          ? const Image(
                                              width: 17,
                                              height: 17,
                                              image: AssetImage(icXP),
                                            )
                                          : const Image(
                                              width: 17,
                                              height: 17,
                                              image: AssetImage(icCircleCheck),
                                            ),
                                      const SizedBox(width: 5),
                                      Text(
                                        canClaimBonus
                                            ? '15 XP'
                                            : 'sudah diklaim',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0XFF000000),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              if (canClaimBonus) {
                                await claimDailyXP();
                              }
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Container(
                              height: 31,
                              decoration: BoxDecoration(
                                color: canClaimBonus
                                    ? const Color(0XFF118611)
                                    : const Color(0XFF87C286),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 232, 236, 243),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                canClaimBonus ? 'Kumpulkan' : '15 XP Terkumpul',
                                style: GoogleFonts.poppins(
                                  color: const Color(0XFFFFFFFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: _lessonGrid(),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Stream<double> getLessonProgressStream(String category) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(category)
        .collection('lessons')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;

      final completedCount = snapshot.docs
          .where(
            (doc) => doc.data()['isCompleted'] == true,
          )
          .length;

      return completedCount / snapshot.docs.length;
    });
  }

  Future<double> getLessonProgress(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(category)
        .collection('lessons')
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final completedCount = snapshot.docs
        .where(
          (doc) => doc.data()['isCompleted'] == true,
        )
        .length;

    return completedCount / snapshot.docs.length;
  }

  Future<bool> isCategoryLocked(int index) async {
    if (index == 0) return false;

    final prevCategory = categories[index - 1]['id'];
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    final progressSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(prevCategory)
        .collection('lessons')
        .get();

    return progressSnapshot.docs.any(
      (doc) => doc.data()['isCompleted'] != true,
    );
  }

  Widget _lessonGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categories.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildLessonItem(0)],
          ),
        ...List.generate(
          (categories.length - 1) ~/ 2 + 1,
          (rowIndex) {
            final startIndex = 1 + rowIndex * 2;
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  for (int i = startIndex; i < startIndex + 2; i++)
                    if (i < categories.length)
                      Expanded(child: _buildLessonItem(i))
                    else
                      const Expanded(
                        child: SizedBox(width: 90),
                      ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLessonItem(int index) {
    final category = categories[index];
    final categoryId = category['id'];
    final iconLockUrl = category['iconLockUrl'];
    final iconUnlockUrl = category['iconUnlockUrl'];

    return FutureBuilder<bool>(
      future: isCategoryLocked(index),
      builder: (context, snapshot) {
        final isLocked = snapshot.data ?? true;

        return GestureDetector(
          onTap: () async {
            if (!isLocked) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonListScreen(category: categoryId),
                ),
              );
              if (mounted) setState(() {});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pelajaran masih terkunci'),
                ),
              );
            }
          },
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (!isLocked)
                    StreamBuilder<double>(
                      stream: getLessonProgressStream(categoryId),
                      builder: (context, progressSnapshot) {
                        final progress = progressSnapshot.data ?? 0.0;
                        final isUnlockedWithProgress = progress > 0;
                        final iconUrl = isUnlockedWithProgress
                            ? iconUnlockUrl
                            : iconLockUrl;

                        return CircularPercentIndicator(
                          radius: 45.0,
                          lineWidth: 4.0,
                          percent: progress,
                          center: Container(
                            width: 80,
                            height: 80,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 46,
                              height: 46,
                              child: Image.network(
                                iconUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          progressColor: const Color(0XFF7EB17E),
                          backgroundColor: const Color(0XFFE0E0E0),
                          circularStrokeCap: CircularStrokeCap.round,
                        );
                      },
                    ),
                  if (isLocked)
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0XFFF1F1F1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 46,
                        height: 46,
                        child: Image.network(
                          iconLockUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  if (isLocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0XFF7EB17E),
                        ),
                        child: const Image(
                          width: 8,
                          height: 10.5,
                          image: AssetImage(icLock),
                          color: Color(0XFFFFFFFF),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                capitalize(categoryId),
                style: GoogleFonts.poppins(
                  color: const Color(0XFF000000),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFFFFFF),
      body: isDataReady
          ? IndexedStack(
              index: _selectedIndex,
              children: [
                _buildCategoryGrid(),
                const LeaderboardScreen(),
                const AlphabetScreen(),
                ProfileScreen(key: _profileScreenKey),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF118611),
              ),
            ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          elevation: 20,
          backgroundColor: const Color(0XFFFFFFFF),
          selectedItemColor: const Color(0XFF118611),
          unselectedItemColor: const Color(0XFF999999),
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Image(
                  width: 20,
                  height: 22,
                  image: const AssetImage(icHome),
                  color: _getIconColor(0),
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Image(
                  width: 22,
                  height: 22,
                  image: const AssetImage(icLeaderboard),
                  color: _getIconColor(1),
                ),
              ),
              label: 'Peringkat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Image(
                  width: 20,
                  height: 25,
                  image: const AssetImage(icAlphabet),
                  color: _getIconColor(2),
                ),
              ),
              label: 'Alphabet',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Image(
                  width: 21,
                  height: 24,
                  image: const AssetImage(icProfile),
                  color: _getIconColor(3),
                ),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
