// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deaflypedia_app/utils/assert_image.dart';
import 'package:deaflypedia_app/utils/custom_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/custom_button.dart';
import '../../utils/custom_button_off.dart';
import '../../utils/custom_progress_bar.dart';
import 'signup_finish_screen.dart';

class SignupProfilePictureScreen extends StatefulWidget {
  final String username;
  final String age;
  const SignupProfilePictureScreen(
      {super.key, required this.username, required this.age});

  @override
  State<SignupProfilePictureScreen> createState() =>
      _SignupProfilePictureScreenState();
}

class _SignupProfilePictureScreenState
    extends State<SignupProfilePictureScreen> {
  int? selectedIndex;
  List<String> avatarUrls = [];
  bool isLoading = true;
  bool isSaving = false;
  String errorMessage = '';
  bool get isFormValid => selectedIndex != null;

  @override
  void initState() {
    super.initState();
    fetchAvatarsFromFirestore();
  }

  Future<void> createGlobalCategories() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final List<Map<String, dynamic>> globalCategories = [
        {
          'id': 'ekspresi umum',
          'order': '1',
          'iconLockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_expression_lock_bytujx.png',
          'iconUnlockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_expression_unlock_i69cdu.png',
          'lessons': [
            {
              'id': 'lesson_1',
              'lessonTitle': 'Pelajaran 1',
              'lessonDescription': 'Belajar kosakata dasar',
              'content': [
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/oke_niywpt.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Oke'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/maaf_npbbjw.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Maaf'
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/oke_niywpt.gif',
                  'options': ['Oke', 'Maaf'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/betul_e5xstj.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Betul'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/salah_lfnyxf.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Salah'
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/betul_e5xstj.gif',
                  'options': ['Salah', 'Betul'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/sakit_eowpin.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Sakit'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/lelah_bhmoby.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Lelah'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sakit_eowpin.gif',
                      'text': 'Sakit'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/lelah_bhmoby.gif',
                      'text': 'Lelah'
                    }
                  ],
                  'questionText': 'Lelah',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/sibuk_enw3re.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Sibuk'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/tidak_apa-apa_ph3avi.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Tidak Apa-apa'
                },
                {
                  'correctOptionIndex': 0,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/tidak_apa-apa_ph3avi.gif',
                      'text': 'Tidak Apa-apa'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sibuk_enw3re.gif',
                      'text': 'Sibuk'
                    }
                  ],
                  'questionText': 'Tidak Apa-apa',
                  'type': 'gif_quiz',
                },
              ]
            },
            {
              'id': 'lesson_2',
              'lessonTitle': 'Pelajaran 2',
              'lessonDescription': 'Belajar kosakata ikonik',
              'content': [
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/salah_lfnyxf.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/salah_ooi9w9.png',
                      'text': 'Salah'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/oke_dduupc.png',
                      'text': 'Oke'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/betul_e5xstj.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/salah_ooi9w9.png',
                      'text': 'Salah'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/betul_em6iog.png',
                      'text': 'Betul'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/maaf_npbbjw.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sibuk_kcoarr.png',
                      'text': 'Sibuk'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/maaf_zh4vfu.png',
                      'text': 'Maaf'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/lelah_awkmcd.png',
                      'text': 'Lelah'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/tidak_apa-apa_a8r4b2.png',
                      'text': 'Tidak Apa-apa'
                    }
                  ],
                  'correctMatches': {'0': 1, '1': 0},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/tidak_apa-apa_ph3avi.gif',
                      'text': 'Tidak Apa-apa'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/lelah_bhmoby.gif',
                      'text': 'Lelah'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/betul_em6iog.png',
                      'text': 'Betul'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/salah_ooi9w9.png',
                      'text': 'Salah'
                    }
                  ],
                  'correctMatches': {'0': 0, '1': 1},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/betul_e5xstj.gif',
                      'text': 'Betul'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/salah_lfnyxf.gif',
                      'text': 'Salah'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                }
              ]
            },
            {
              'id': 'lesson_3',
              'lessonTitle': 'Pelajaran 3',
              'lessonDescription': 'Mari berlatih!',
              'content': [
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': '_____ saya tidak sengaja mendorongmu',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/maaf_npbbjw.gif',
                  'options': ['Oke', 'Maaf'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Guru bilang _____ setelah saya menjawab benar',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/betul_e5xstj.gif',
                  'options': ['salah', 'betul'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': 'Saya merasa _____ setelah bermain seharian',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/lelah_bhmoby.gif',
                  'options': ['lelah', 'sakit'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctAnswer': 'Maaf',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/maaf_npbbjw.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Lelah',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/lelah_bhmoby.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Sibuk',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/sibuk_enw3re.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
              ]
            },
          ]
        },
        {
          'id': 'orang & keluarga',
          'order': '2',
          'iconLockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_family_lock_mt1jwz.png',
          'iconUnlockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_family_unlock_wmxknl.png',
          'lessons': [
            {
              'id': 'lesson_1',
              'lessonTitle': 'Pelajaran 1',
              'lessonDescription': 'Belajar kosakata dasar',
              'content': [
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bapak_ft7s4x.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Bapak'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ibu_tht1sm.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Ibu'
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ibu_tht1sm.gif',
                  'options': ['Bapak', 'Ibu'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/anak_freew7.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Anak'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bayi_qlzcgt.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Bayi'
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/anak_freew7.gif',
                  'options': ['Bayi', 'Anak'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kakek_bjoyhm.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Kakek'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/nenek_nlwpwi.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Nenek'
                },
                {
                  'correctOptionIndex': 0,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/nenek_nlwpwi.gif',
                      'text': 'Nenek'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kakek_bjoyhm.gif',
                      'text': 'Kakek'
                    }
                  ],
                  'questionText': 'Nenek',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/saudara_bu2bio.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Saudara'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/teman_vozjkq.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Teman'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/teman_vozjkq.gif',
                      'text': 'Teman'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/saudara_bu2bio.gif',
                      'text': 'Saudara'
                    }
                  ],
                  'questionText': 'Saudara',
                  'type': 'gif_quiz',
                },
              ]
            },
            {
              'id': 'lesson_2',
              'lessonTitle': 'Pelajaran 2',
              'lessonDescription': 'Belajar kosakata ikonik',
              'content': [
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kakek_bjoyhm.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bapak_aaba2e.png',
                      'text': 'Bapak'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kakek_tflhtn.png',
                      'text': 'Kakek'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ibu_tht1sm.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/nenek_pg89dw.png',
                      'text': 'Nenek'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/ibu_nf3oui.png',
                      'text': 'Ibu'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/anak_freew7.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bayi_cdkl7q.png',
                      'text': 'Bayi'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/anak_lsbnyi.png',
                      'text': 'Anak'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/saudara_ir36gi.png',
                      'text': 'Saudara'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/teman_bbuwlb.png',
                      'text': 'Teman'
                    }
                  ],
                  'correctMatches': {'0': 0, '1': 1},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/saudara_bu2bio.gif',
                      'text': 'Saudara'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/teman_vozjkq.gif',
                      'text': 'Teman'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/anak_lsbnyi.png',
                      'text': 'Anak'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bayi_cdkl7q.png',
                      'text': 'Bayi'
                    }
                  ],
                  'correctMatches': {'0': 1, '1': 0},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bayi_qlzcgt.gif',
                      'text': 'Bayi'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/anak_freew7.gif',
                      'text': 'Anak'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                }
              ]
            },
            {
              'id': 'lesson_3',
              'lessonTitle': 'Pelajaran 3',
              'lessonDescription': 'Mari berlatih!',
              'content': [
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Nenek dan _____ suka bermain dengan saya',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kakek_bjoyhm.gif',
                  'options': ['teman', 'kakek'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': '_____ saya kerja di kantor',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bapak_ft7s4x.gif',
                  'options': ['Bapak', 'Kakek'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Adik saya masih kecil, dia seorang _____',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bayi_qlzcgt.gif',
                  'options': ['adik', 'bayi'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctAnswer': 'Ibu',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ibu_tht1sm.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Teman',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/teman_vozjkq.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Anak',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/anak_freew7.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
              ]
            },
          ]
        },
        {
          'id': 'sekolah & aktivitas belajar',
          'order': '3',
          'iconLockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_school_lock_d8ncgr.png',
          'iconUnlockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_school_unlock_ginhgj.png',
          'lessons': [
            {
              'id': 'lesson_1',
              'lessonTitle': 'Pelajaran 1',
              'lessonDescription': 'Belajar kosakata dasar',
              'content': [
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/guru_bud9g9.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Guru'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/murid_jkuhjk.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Murid'
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/guru_bud9g9.gif',
                  'options': ['Guru', 'Murid'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/mulai_ulu2le.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Mulai'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/terakhir_adhtcg.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Terakhir'
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/terakhir_adhtcg.gif',
                  'options': ['Terakhir', 'Mulai'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bertanya_vlbqjw.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Bertanya'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/latihan_c7yhyt.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Latihan'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/latihan_c7yhyt.gif',
                      'text': 'Latihan'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bertanya_vlbqjw.gif',
                      'text': 'Bertanya'
                    }
                  ],
                  'questionText': 'Bertanya',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/sulit_hetkgy.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Sulit'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/lama_y3tykc.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Lama'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sulit_hetkgy.gif',
                      'text': 'Sulit'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/lama_y3tykc.gif',
                      'text': 'Lama'
                    }
                  ],
                  'questionText': 'Lama',
                  'type': 'gif_quiz',
                },
              ]
            },
            {
              'id': 'lesson_2',
              'lessonTitle': 'Pelajaran 2',
              'lessonDescription': 'Belajar kosakata ikonik',
              'content': [
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/murid_jkuhjk.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/guru_ykuabj.png',
                      'text': 'Guru'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/murid_zyxkh6.png',
                      'text': 'Murid'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/terakhir_adhtcg.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/terakhir_vzie7m.png',
                      'text': 'Terakhir'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/mulai_kyuese.png',
                      'text': 'Mulai'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/sulit_hetkgy.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sulit_ingzdc.png',
                      'text': 'Sulit'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/latihan_slwlcq.png',
                      'text': 'Latihan'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sama_wcsynw.png',
                      'text': 'Sama'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/beda_fgmsxf.png',
                      'text': 'Beda'
                    }
                  ],
                  'correctMatches': {'0': 1, '1': 0},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/beda_nedgtt.gif',
                      'text': 'Beda'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sama_d3dhj5.gif',
                      'text': 'Sama'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/latihan_slwlcq.png',
                      'text': 'Latihan'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sulit_ingzdc.png',
                      'text': 'Sulit'
                    }
                  ],
                  'correctMatches': {'0': 1, '1': 0},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/sulit_hetkgy.gif',
                      'text': 'Sulit'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/latihan_c7yhyt.gif',
                      'text': 'Latihan'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                }
              ]
            },
            {
              'id': 'lesson_3',
              'lessonTitle': 'Pelajaran 3',
              'lessonDescription': 'Mari berlatih!',
              'content': [
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': 'Saya ingin _____ sebelum ujian',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/latihan_c7yhyt.gif',
                  'options': ['latihan', 'sulit'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': 'Jawaban saya _____ dengan teman',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/sama_d3dhj5.gif',
                  'options': ['sama', 'beda'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Pelajaran akan _____ saat guru masuk kelas',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/mulai_ulu2le.gif',
                  'options': ['terakhir', 'mulai'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctAnswer': 'Guru',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/guru_bud9g9.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Murid',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/murid_jkuhjk.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Bertanya',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bertanya_vlbqjw.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
              ]
            },
          ]
        },
        {
          'id': 'pertanyaan dasar',
          'order': '4',
          'iconLockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_question_lock_q8mwv9.png',
          'iconUnlockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_question_unlock_oagxo5.png',
          'lessons': [
            {
              'id': 'lesson_1',
              'lessonTitle': 'Pelajaran 1',
              'lessonDescription': 'Belajar kosakata dasar',
              'content': [
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/apa_dnbmca.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Apa'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/siapa_tthexi.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Siapa'
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/apa_dnbmca.gif',
                  'options': ['Siapa', 'Apa'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/dimana_t9bpr7.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Dimana'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kapan_vkxyki.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Kapan'
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/dimana_t9bpr7.gif',
                  'options': ['Dimana', 'Kapan'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kenapa_gf21yi.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Kenapa'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_edegey.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Bagaimana'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_edegey.gif',
                      'text': 'Bagaimana'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kenapa_gf21yi.gif',
                      'text': 'Kenapa'
                    }
                  ],
                  'questionText': 'Kenapa',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/berapa_kyqxlo.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Berapa'
                },
                {
                  'correctOptionIndex': 0,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/apa_dnbmca.gif',
                      'text': 'Apa'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/berapa_kyqxlo.gif',
                      'text': 'Berapa'
                    }
                  ],
                  'questionText': 'Apa',
                  'type': 'gif_quiz',
                },
              ]
            },
            {
              'id': 'lesson_2',
              'lessonTitle': 'Pelajaran 2',
              'lessonDescription': 'Belajar kosakata ikonik',
              'content': [
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/siapa_tthexi.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/dimana_eqgsue.png',
                      'text': 'Dimana'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/siapa_tl4yia.png',
                      'text': 'Siapa'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kapan_vkxyki.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kapan_zhkmor.png',
                      'text': 'Kapan'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/berapa_dtv5ii.png',
                      'text': 'Berapa'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_edegey.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/apa_x2c5px.png',
                      'text': 'Apa'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_sju74d.png',
                      'text': 'Bagaimana'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kenapa_kmft5h.png',
                      'text': 'Kenapa'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_sju74d.png',
                      'text': 'Bagaimana'
                    }
                  ],
                  'correctMatches': {'0': 1, '1': 0},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_edegey.gif',
                      'text': 'Bagaimana'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kenapa_gf21yi.gif',
                      'text': 'Kenapa'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/siapa_tl4yia.png',
                      'text': 'Siapa'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/berapa_dtv5ii.png',
                      'text': 'Berapa'
                    }
                  ],
                  'correctMatches': {'0': 0, '1': 1},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/siapa_tthexi.gif',
                      'text': 'Siapa'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/berapa_kyqxlo.gif',
                      'text': 'Berapa'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                }
              ]
            },
            {
              'id': 'lesson_3',
              'lessonTitle': 'Pelajaran 3',
              'lessonDescription': 'Mari berlatih!',
              'content': [
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': '_____ namamu?',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/siapa_tthexi.gif',
                  'options': ['Apa', 'Siapa'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Kita belajar _____ hari ini?',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/apa_dnbmca.gif',
                  'options': ['dimana', 'apa'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': 'Ayah bekerja di _____',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/dimana_t9bpr7.gif',
                  'options': ['dimana', 'kapan'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctAnswer': 'Kenapa',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kenapa_gf21yi.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Bagaimana',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/bagaimana_edegey.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Berapa',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/berapa_kyqxlo.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
              ]
            },
          ]
        },
        {
          'id': 'warna',
          'order': '5',
          'iconLockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_colors_lock_lc3b9t.png',
          'iconUnlockUrl':
              'https://res.cloudinary.com/dqyicvxey/image/upload/ic_colors_unlock_kdkms5.png',
          'lessons': [
            {
              'id': 'lesson_1',
              'lessonTitle': 'Pelajaran 1',
              'lessonDescription': 'Belajar kosakata dasar',
              'content': [
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/merah_ud4a5s.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Merah'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/biru_jtq3e3.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Biru'
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/merah_ud4a5s.gif',
                  'options': ['Biru', 'Merah'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kuning_exzgih.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Kuning'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_t7vfjf.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Hijau'
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_t7vfjf.gif',
                  'options': ['Kuning', 'Hijau'],
                  'questionText': 'Ayo tebak, ini kata apa?',
                  'type': 'quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/putih_p33j06.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Putih'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/hitam_trggm4.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Hitam'
                },
                {
                  'correctOptionIndex': 0,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/putih_p33j06.gif',
                      'text': 'Putih'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hitam_trggm4.gif',
                      'text': 'Hitam'
                    }
                  ],
                  'questionText': 'Putih',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/abu-abu_jjs5cn.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Abu-abu'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/jingga_jfmyks.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Jingga'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/abu-abu_jjs5cn.gif',
                      'text': 'Abu-abu'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/jingga_jfmyks.gif',
                      'text': 'Jingga'
                    }
                  ],
                  'questionText': 'Jingga',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/merah_muda_u4qgll.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Merah Muda'
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ilgxeq.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Ungu'
                },
                {
                  'correctOptionIndex': 0,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ilgxeq.gif',
                      'text': 'Ungu'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/merah_muda_u4qgll.gif',
                      'text': 'Merah Muda'
                    }
                  ],
                  'questionText': 'Ungu',
                  'type': 'gif_quiz',
                },
                {
                  'contentTitle': 'Belajar kosakata baru!',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/coklat_frkre9.gif',
                  'type': 'vocabulary',
                  'vocabularyText': 'Coklat'
                },
                {
                  'correctOptionIndex': 1,
                  'options': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_t7vfjf.gif',
                      'text': 'Hitam'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/coklat_frkre9.gif',
                      'text': 'Coklat'
                    }
                  ],
                  'questionText': 'Coklat',
                  'type': 'gif_quiz',
                },
              ]
            },
            {
              'id': 'lesson_2',
              'lessonTitle': 'Pelajaran 2',
              'lessonDescription': 'Belajar kosakata ikonik',
              'content': [
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kuning_exzgih.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kuning_qmds0f.png',
                      'text': ' Kuning'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_nvlxyh.png',
                      'text': 'Hijau'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/biru_jtq3e3.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/coklat_qxdosx.png',
                      'text': 'Coklat'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/biru_bnqcrh.png',
                      'text': 'Biru'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ilgxeq.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/merah_muda_jttzmn.png',
                      'text': 'Merah Muda'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ggvqzn.png',
                      'text': 'Ungu'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/putih_p33j06.gif',
                  'options': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/putih_b71168.png',
                      'text': 'Putih'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/abu-abu_dsesxe.png',
                      'text': 'Abu-abu'
                    }
                  ],
                  'questionText': 'Menurutmu, ini kata apa?',
                  'type': 'gif_image_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kuning_qmds0f.png',
                      'text': 'Kuning'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/merah_hg8sa7.png',
                      'text': 'Merah'
                    }
                  ],
                  'correctMatches': {'0': 0, '1': 1},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/kuning_exzgih.gif',
                      'text': 'Kuning'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/merah_ud4a5s.gif',
                      'text': 'Merah'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/putih_b71168.png',
                      'text': 'Putih'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_nvlxyh.png',
                      'text': 'Hijau'
                    }
                  ],
                  'correctMatches': {'0': 1, '1': 0},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_t7vfjf.gif',
                      'text': 'Hijau'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/putih_p33j06.gif',
                      'text': 'Putih'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ggvqzn.png',
                      'text': 'Ungu'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/coklat_qxdosx.png',
                      'text': 'Coklat'
                    }
                  ],
                  'correctMatches': {'0': 0, '1': 1},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ilgxeq.gif',
                      'text': 'Ungu'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/coklat_frkre9.gif',
                      'text': 'Coklat'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
                {
                  'bottomItems': [
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/abu-abu_dsesxe.png',
                      'text': 'Abu-abu'
                    },
                    {
                      'imageUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hitam_ghfwvc.png',
                      'text': 'Hitam'
                    }
                  ],
                  'correctMatches': {'0': 0, '1': 1},
                  'questionText': 'Cocokkan pasangan yang benar',
                  'topItems': [
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/abu-abu_jjs5cn.gif',
                      'text': 'Abu-abu'
                    },
                    {
                      'gifUrl':
                          'https://res.cloudinary.com/dqyicvxey/image/upload/hitam_trggm4.gif',
                      'text': 'Hitam'
                    }
                  ],
                  'type': 'gif_image_matching_quiz',
                },
              ]
            },
            {
              'id': 'lesson_3',
              'lessonTitle': 'Pelajaran 3',
              'lessonDescription': 'Mari berlatih!',
              'content': [
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': 'Mobil ayah berwarna _____',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/hitam_trggm4.gif',
                  'options': ['hitam', 'merah'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 0,
                  'fullPhrase': 'Langit pagi terlihat berwarna _____',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/biru_jtq3e3.gif',
                  'options': ['biru', 'putih'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Daun di taman berwarna _____',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/hijau_t7vfjf.gif',
                  'options': ['kuning', 'hijau'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctOptionIndex': 1,
                  'fullPhrase': 'Topi adik warnanya _____',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/ungu_ilgxeq.gif',
                  'options': ['merah muda', 'ungu'],
                  'questionText': 'Lengkapi kata yang hilang',
                  'type': 'gif_missing_word_quiz',
                },
                {
                  'correctAnswer': 'Kuning',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/kuning_exzgih.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Putih',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/putih_p33j06.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
                {
                  'correctAnswer': 'Jingga',
                  'gifUrl':
                      'https://res.cloudinary.com/dqyicvxey/image/upload/jingga_jfmyks.gif',
                  'questionText': 'Tulis kata yang ditunjukkan!',
                  'type': 'gif_input_word_quiz',
                },
              ]
            },
          ]
        },
      ];

      final batch = firestore.batch();

      for (final category in globalCategories) {
        final categoryId = category['id'] as String;
        final categoryRef = firestore.collection('categories').doc(categoryId);

        batch.set(categoryRef, {
          'id': categoryId,
          'order': category['order'],
          'iconLockUrl': category['iconLockUrl'],
          'iconUnlockUrl': category['iconUnlockUrl'],
        });

        final lessons = category['lessons'] as List<dynamic>;
        for (final lesson in lessons) {
          final lessonData = lesson as Map<String, dynamic>;
          final lessonRef =
              categoryRef.collection('lessons').doc(lessonData['id'] as String);

          batch.set(lessonRef, {
            'lessonTitle': lessonData['lessonTitle'] as String,
            'lessonDescription': lessonData['lessonDescription'] as String,
            'content': lessonData['content'] as List<dynamic>,
          });
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori global berhasil dibuat!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> fetchAvatarsFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('avatars').get();

      final urls = snapshot.docs
          .map((doc) => doc.data()['avatarUrl'] as String)
          .where((url) => url.isNotEmpty)
          .toList();

      setState(() {
        avatarUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching avatars: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> initializeAllLessonProgress(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final categoriesSnapshot = await firestore.collection('categories').get();

    const lessonCount = 3;

    for (final doc in categoriesSnapshot.docs) {
      final categoryId = doc.id;

      final progressDocRef = firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(categoryId);

      await progressDocRef.set({
        'id': categoryId,
      });

      final lessonsRef = progressDocRef.collection('lessons');

      for (int i = 1; i <= lessonCount; i++) {
        await lessonsRef.doc('lesson_$i').set({
          'isCompleted': false,
          'isLocked': i == 1 ? false : true,
          'lastAccessed': null,
          'score': 0,
        });
      }
    }
  }

  Future<void> signUp() async {
    setState(() {
      isSaving = true;
      errorMessage = '';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CustomLoading(),
        );
      },
    );

    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;

      if (user == null) {
        Navigator.pop(context);
        setState(() {
          errorMessage = 'Gagal membuat akun.';
          isSaving = false;
        });
        return;
      }

      final avatarUrl = avatarUrls[selectedIndex!];

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': widget.username,
        'age': widget.age,
        'avatar': avatarUrl,
        'xp': 0,
        'streak': 1,
        'isyarat': 0,
        'createdAt': Timestamp.now(),
        'lastActivityDate': Timestamp.fromDate(
          DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day),
        ),
      });

      await initializeAllLessonProgress(user.uid);

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignupFinishScreen(
            username: widget.username,
            age: widget.age,
            avatar: avatarUrl,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat menyimpan data: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
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
                  child: CustomProgressBar(value: 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Pilih avatar untuk\nprofil Anda',
                    style: GoogleFonts.poppins(
                      color: const Color(0XFF000000),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  if (isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: avatarUrls.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = isSelected ? null : index;
                              });
                            },
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 87,
                                    height: 87,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0XFF4CAF50)
                                            : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        avatarUrls[index],
                                        width: 87,
                                        height: 87,
                                        fit: BoxFit.cover,
                                        color: isSelected
                                            ? const Color(0XFF000000)
                                                .withOpacity(0.3)
                                            : null,
                                        colorBlendMode: isSelected
                                            ? BlendMode.darken
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Image(
                                      width: 25,
                                      height: 19,
                                      image: AssetImage(icCheck),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          // TextButton(
          //   onPressed: createGlobalCategories,
          //   child: Text(
          //     'Buat Kategori Global (Admin Only)',
          //     style: GoogleFonts.poppins(
          //       color: const Color(0XFF4CAF50),
          //       fontWeight: FontWeight.bold,
          //       fontSize: 14,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: isFormValid
                ? CustomButton(
                    ontap: signUp,
                    title: 'Daftar',
                  )
                : CustomButtonOff(
                    ontap: () {},
                    title: 'Daftar',
                  ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
