import '../../utils/assert_image.dart';

class ResultFeedback {
  final String title;
  final String subtitle;
  final String imageAsset;

  ResultFeedback({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}

ResultFeedback getResultFeedback(int percentage) {
  if (percentage >= 80) {
    return ResultFeedback(
      title: 'Yeay, keren banget!',
      subtitle: 'Kamu berhasil menyelesaikan pelajaran.',
      imageAsset: ilustrasi3,
    );
  } else {
    return ResultFeedback(
      title: 'Ayo semangat!',
      subtitle: 'Yuk ulangi dan capai skor 80% ke atas.',
      imageAsset: ilustrasi4,
    );
  }
}
