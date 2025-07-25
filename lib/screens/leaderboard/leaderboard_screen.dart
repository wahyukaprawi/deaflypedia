import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Stream<QuerySnapshot> getLeaderboardStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(20)
        .snapshots();
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
                  image: AssetImage(bgLeaderboard),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'Peringkat',
                  style: GoogleFonts.poppins(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: getLeaderboardStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Kesalahan memuat halaman peringkat',
                          style: GoogleFonts.poppins(
                            color: const Color(0XFF000000),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      );
                    }
                    final users = snapshot.data!.docs;
                    if (users.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ditemukan pengguna',
                          style: GoogleFonts.poppins(
                            color: const Color(0XFF000000),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    }
                    final topThree =
                        users.length >= 3 ? users.sublist(0, 3) : users;
                    final otherUsers = users.length > 3 ? users.sublist(3) : [];
                    return Column(
                      children: [
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (topThree.length > 1)
                                Expanded(
                                  child: buildTopUser(topThree[1], 2,
                                      offset: const Offset(0, 30)),
                                ),
                              if (topThree.isNotEmpty)
                                Expanded(
                                  child: buildTopUser(topThree[0], 1),
                                ),
                              if (topThree.length > 2)
                                Expanded(
                                  child: buildTopUser(topThree[2], 3,
                                      offset: const Offset(0, 30)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 59),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                              left: 25, right: 25, top: 25, bottom: 10),
                          decoration: const BoxDecoration(
                            color: Color(0XFFFFFFFF),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35),
                            ),
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: otherUsers.length,
                            itemBuilder: (context, index) {
                              var user = otherUsers[index];
                              final avatarUrl = user['avatar'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Container(
                                  width: double.infinity,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0XFFFFFFFF),
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: const Color(0XFFEEEEEE),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${index + 4}.',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0XFF000000),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ClipOval(
                                          child: Image.network(
                                            avatarUrl,
                                            width: 45,
                                            height: 45,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              defaultImage,
                                              width: 45,
                                              height: 45,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          user['username'] ?? 'guest',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0XFF000000),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        const Image(
                                          width: 17,
                                          height: 17,
                                          image: AssetImage(icXP),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${user['xp'] ?? 0} XP',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0XFF000000),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopUser(DocumentSnapshot user, int rank,
      {Offset offset = Offset.zero}) {
    final medalIcon = rank == 1
        ? const AssetImage(icMedal1)
        : rank == 2
            ? const AssetImage(icMedal2)
            : const AssetImage(icMedal3);
    final avatarUrl = user['avatar'];
    return Transform.translate(
      offset: offset,
      child: Column(
        children: [
          Stack(
            children: [
              ClipOval(
                child: Image.network(
                  avatarUrl,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    defaultImage,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image(width: 25, height: 24, image: medalIcon),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user['username'] ?? 'guest',
            style: GoogleFonts.poppins(
              color: const Color(0XFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${user['xp'] ?? 0} XP',
            style: GoogleFonts.poppins(
              color: const Color(0XFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
