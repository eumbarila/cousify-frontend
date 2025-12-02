import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cousify_frontend/services/local_database.dart';
import 'package:cousify_frontend/services/sync_service.dart';
import 'package:cousify_frontend/utils/colors.dart';

class OfflineVideoPlayer extends StatefulWidget {
  final int courseId;
  final String courseName;

  const OfflineVideoPlayer({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  State<OfflineVideoPlayer> createState() => _OfflineVideoPlayerState();
}

class _OfflineVideoPlayerState extends State<OfflineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  double _currentProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Obtener el curso de la base de datos local
      final course = await LocalDatabase.getCourse(widget.courseId);

      if (course == null) {
        setState(() {
          _errorMessage = 'Course not found in downloads';
          _isLoading = false;
        });
        return;
      }

      final videoPath = course['video_path'] as String?;
      if (videoPath == null) {
        setState(() {
          _errorMessage = 'Video file not found';
          _isLoading = false;
        });
        return;
      }

      // Inicializar el reproductor de video con el archivo local
      _controller = VideoPlayerController.file(File(videoPath));

      await _controller!.initialize();

      // Listener para actualizar progreso
      _controller!.addListener(_onVideoProgress);

      setState(() {
        _isLoading = false;
      });

      // Reproducir automáticamente
      _controller!.play();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading video: $e';
        _isLoading = false;
      });
    }
  }

  void _onVideoProgress() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final position = _controller!.value.position.inSeconds;
    final duration = _controller!.value.duration.inSeconds;

    if (duration > 0) {
      final progress = (position / duration * 100);

      // Actualizar progreso cada 5%
      if ((progress - _currentProgress).abs() >= 5) {
        _currentProgress = progress;
        _saveProgress(progress);
      }
    }
  }

  Future<void> _saveProgress(double progress) async {
    // Guardar progreso localmente (se sincronizará automáticamente cuando haya internet)
    await SyncService.updateProgress(widget.courseId, progress);
    print('Progress saved: ${progress.toStringAsFixed(1)}%');
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _controller != null && _controller!.value.isInitialized
                  ? Column(
                      children: [
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                        const SizedBox(height: 16),
                        _buildControls(),
                        const SizedBox(height: 16),
                        _buildProgressInfo(),
                      ],
                    )
                  : const Center(child: Text('Failed to load video')),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: AppColors.primaryColor,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller!.value.isPlaying) {
                      _controller!.pause();
                    } else {
                      _controller!.play();
                    }
                  });
                },
              ),
              const SizedBox(width: 16),
              Text(
                _formatDuration(_controller!.value.position),
                style: const TextStyle(fontSize: 14),
              ),
              const Text(' / '),
              Text(
                _formatDuration(_controller!.value.duration),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Progress is saved automatically (${_currentProgress.toStringAsFixed(0)}%). It will sync when you go online.',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
