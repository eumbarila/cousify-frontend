import 'package:flutter/material.dart';
import 'package:cousify_frontend/utils/colors.dart';
import 'package:cousify_frontend/models/course.dart';
import 'package:cousify_frontend/screens/CourseContentScreen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with TickerProviderStateMixin {
  bool _showOptions = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
    if (_showOptions) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleOptionTap(String option) {
    _toggleOptions();
    Future.delayed(Duration(milliseconds: 200), () {
      switch (option) {
        case 'download':
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Downloading course...')));
          break;
        case 'favorite':
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Added to favorites!')));
          break;
        case 'ai':
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('AI Chat coming soon!')));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Course Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Image
                  if (widget.course.titleImage != null)
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.course.titleImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  // Course Title
                  Text(
                    widget.course.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Rating and Start Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating Stars
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < widget.course.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      // Start Course Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CourseContentScreen(course: widget.course),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Start Course'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${widget.course.progress.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: widget.course.progress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Tags
                  if (widget.course.tags != null &&
                      widget.course.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.course.tags!.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 24),

                  // Description Section
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.course.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Learning Goals Section
                  Text(
                    'Learning Goals',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.course.learningGoals
                        .map(
                          (goal) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 6, right: 8),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    goal,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 24),

                  // Duration Info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Duration: ${widget.course.duration}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Overlay and options
          if (_showOptions)
            GestureDetector(
              onTap: _toggleOptions,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
                    child: Stack(
                      children: [
                        // Options positioned above the FAB
                        Positioned(
                          right: 16,
                          bottom: 160, // Above the FAB
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildFloatingOption(
                                    Icons.download_outlined,
                                    'Download course',
                                    () => _handleOptionTap('download'),
                                  ),
                                  SizedBox(height: 12),
                                  _buildFloatingOption(
                                    Icons.favorite_border,
                                    'Add to favorites',
                                    () => _handleOptionTap('favorite'),
                                  ),
                                  SizedBox(height: 12),
                                  _buildFloatingOption(
                                    Icons.smart_toy_outlined,
                                    'Ask to AI',
                                    () => _handleOptionTap('ai'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleOptions,
        backgroundColor: AppColors.primaryColor,
        child: AnimatedRotation(
          turns: _showOptions ? 0.125 : 0, // 45 degrees rotation
          duration: Duration(milliseconds: 300),
          child: Icon(
            _showOptions ? Icons.close : Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingOption(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 20),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
