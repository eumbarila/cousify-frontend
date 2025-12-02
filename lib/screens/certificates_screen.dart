import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/services/api_service.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/utils/download_pdf.dart';

import 'LoginScreen.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late Future<List<Course>> _futureCourses;
  final TextEditingController _certificateCodeController = TextEditingController();
  String _validationMessage = '';
  bool _isValidCode = false;

  @override
  void initState() {
    super.initState();
    _futureCourses = _loadCompletedCourses();
  }

  Future<List<Course>> _loadCompletedCourses() async {
    final rawCourses = await ApiService.getCourses();
    return rawCourses
        .map((c) => Course.fromJson(c))
        .where((course) => course.progress == 100)
        .toList();
  }

  void _handleDownloadCertificate(Course course) async {
    try {
      final json = await ApiService.downloadCertificate(course.id);

      final pdfUrl = json['pdf_url'];
      final code = json['certificate_code'];

      await downloadPdfFile(
        url: pdfUrl,
        filename: "certificate_$code.pdf",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Certificate downloaded')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _validateCertificateCode() async {
    final certificateCode = _certificateCodeController.text.trim();
    if (certificateCode.isEmpty) {
      return;
    }

    try {
      bool isValid = false;
      if (certificateCode.length >= 2 && int.tryParse(certificateCode.substring(certificateCode.length - 2)) != null) {
        isValid = await ApiService.validateCertificate(certificateCode);
      }
      setState(() {
        _isValidCode = isValid;
        if (isValid) {
          _validationMessage =
          "The code provided does belong to a verified Coursify certificate";
        } else {
          _validationMessage =
          "The code provided does not belong to a verified Coursify certificate, check to copy the entire code in the certificate";
        }
      });
    } catch (e) {
      setState(() {
        _validationMessage = "Error validating the certificate code, make sure you are copying a valid code";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Certificates',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: FutureBuilder<List<Course>>(
                    future: _futureCourses,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error loading certificates"));
                      }

                      final courses = snapshot.data ?? [];

                      if (courses.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return _buildCertificateCard(course);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: _showCertificateValidationModal,
          child: const Icon(Icons.check_circle),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleDownloadCertificate(course),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon with circular background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Course title and completed badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title.length > 35
                            ? '${course.title.substring(0, 32)}...'
                            : course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Completed badge/tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Download icon button
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 80,
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No certificates yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete courses to earn certificates',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showCertificateValidationModal() {
    _certificateCodeController.clear();
    setState(() {
      _validationMessage = '';
    });

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Verify a Certificate Code"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _certificateCodeController,
                decoration: const InputDecoration(labelText: "Certificate Code"),
                onChanged: (text) {
                  setState(() {
                    _validationMessage = '';
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _validateCertificateCode();
                  setState(() {});
                },
                child: const Text("Validate"),
              ),
              const SizedBox(height: 16),
              if (_validationMessage.isNotEmpty)
                Text(
                  _validationMessage,
                  style: TextStyle(
                    color: _isValidCode ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
