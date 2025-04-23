import 'package:flutter/material.dart';
import '../../../core/themes/colors.dart';

class StudentPaperScreen extends StatefulWidget {
  final String imageUrl;

  const StudentPaperScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  State<StudentPaperScreen> createState() => _StudentPaperScreenState();
}

class _StudentPaperScreenState extends State<StudentPaperScreen> {
  int _quarterTurns = 1;

  void _rotateImage() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SnapScore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.rotate_right, color: AppColors.textPrimary),
            onPressed: _rotateImage,
            tooltip: 'Rotate image',
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            'Results',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.75,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: RotatedBox(
                    quarterTurns: _quarterTurns,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Failed to load image',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
