import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustGifWithSound extends StatefulWidget {
  final String gifUrl;
  const CustGifWithSound({super.key, required this.gifUrl});

  @override
  State<CustGifWithSound> createState() => CustGifWithSoundState();
}

class CustGifWithSoundState extends State<CustGifWithSound> {
  late VideoPlayerController _controller;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initVideo(widget.gifUrl);
  }

   @override
  void didUpdateWidget(covariant CustGifWithSound oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.gifUrl != widget.gifUrl) {
      _controller.dispose();
      _initVideo(widget.gifUrl);

      setState(() {
        _isMuted = true;
      });
    }
  }

  void _initVideo(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.setLooping(true);
          _controller.setVolume(0);
          _controller.play();
        }
      });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF4CAF50),
          ),
        ),
      );
    }
    if (_controller.value.hasError) {
      return const Center(
        child: Text(
          'Gagal memuat GIF',
        ),
      );
    }
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          width: double.infinity,
          height: 275,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: IconButton(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: const Color(0xFFFFFFFF),
              size: 32,
            ),
            onPressed: _toggleMute,
          ),
        ),
      ],
    );
  }
}
