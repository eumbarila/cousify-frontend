import 'package:flutter/material.dart';
import 'package:cousify_frontend/services/download_service.dart';
import 'package:cousify_frontend/services/local_database.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/utils/colors.dart';

class DownloadButton extends StatefulWidget {
  final Course course;
  final VoidCallback? onDownloadComplete;

  const DownloadButton({
    Key? key,
    required this.course,
    this.onDownloadComplete,
  }) : super(key: key);

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await LocalDatabase.isCourseDownloaded(widget.course.id);
    setState(() {
      _isDownloaded = isDownloaded;
    });
  }

  Future<void> _downloadCourse() async {
    // Verificar que tenga URL de descarga
    if (widget.course.downloadUrl == null || widget.course.downloadUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This course does not have a download URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      await DownloadService.downloadCourse(
        courseId: widget.course.id,
        title: widget.course.title,
        videoUrl: widget.course.downloadUrl!,
        description: widget.course.description,
        thumbnailUrl: widget.course.titleImage,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      setState(() {
        _isDownloading = false;
        _isDownloaded = true;
        _downloadProgress = 100;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onDownloadComplete?.call();
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteCourse() async {
    // Mostrar confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: const Text('Are you sure you want to delete this downloaded course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DownloadService.deleteCourse(widget.course.id);

      setState(() {
        _isDownloaded = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      widget.onDownloadComplete?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            value: _downloadProgress / 100,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            '${_downloadProgress.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (_isDownloaded) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        color: Colors.red,
        tooltip: 'Delete download',
        onPressed: _deleteCourse,
      );
    }

    return IconButton(
      icon: const Icon(Icons.download_rounded),
      color: AppColors.primaryColor,
      tooltip: 'Download for offline',
      onPressed: _downloadCourse,
    );
  }
}
