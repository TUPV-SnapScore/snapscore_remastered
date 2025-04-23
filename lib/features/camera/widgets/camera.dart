// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/camera/services/camera_service.dart';

class Camera extends StatefulWidget {
  final String assessmentName;
  final String assessmentId;

  const Camera({
    super.key,
    required this.assessmentName,
    required this.assessmentId,
  });

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  List<File> _capturedImages = [];
  File? _previewImage; // Currently displayed image in review mode
  bool _isProcessing = false;
  bool _isReviewing = false;
  bool _isUploading = false;
  final cameraService = CameraService();
  final DocumentScanner _documentScanner = DocumentScanner(
    options: DocumentScannerOptions(
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.filter,
      pageLimit: 1,
      isGalleryImport: true,
    ),
  );

  DeviceOrientation _currentOrientation = DeviceOrientation.portraitUp;
  Map<File, DeviceOrientation> _photoOrientations = {};

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
    }
  }

  Future<void> _scanDocument() async {
    try {
      setState(() => _isProcessing = true);

      DocumentScanningResult result = await _documentScanner.scanDocument();

      if (result.images == null || result.images.isEmpty) {
        // User canceled the scanning
        setState(() => _isProcessing = false);
        return;
      }

      // Process each scanned document
      for (final output in result.images) {
        final String imagePath = output;
        final File scannedImage = File(imagePath);

        // Save to app directory for persistence
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String dirPath = '${appDir.path}/Pictures';
        await Directory(dirPath).create(recursive: true);

        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final String savedImagePath =
            '$dirPath${Platform.pathSeparator}$fileName';
        final File savedImage = await scannedImage.copy(savedImagePath);

        setState(() {
          _capturedImages.add(savedImage);
          _photoOrientations[savedImage] = _currentOrientation;
          _previewImage = savedImage;
          _isReviewing = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning document: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  double _getRotationAngle(DeviceOrientation orientation) {
    switch (orientation) {
      case DeviceOrientation.landscapeRight:
        return -90 * 3.14159 / 180;
      case DeviceOrientation.landscapeLeft:
        return 90 * 3.14159 / 180;
      case DeviceOrientation.portraitDown:
        return 180 * 3.14159 / 180;
      case DeviceOrientation.portraitUp:
      default:
        return 0.0;
    }
  }

  void _returnToCamera() {
    setState(() {
      _isReviewing = false;
      _previewImage = null;
    });
  }

  void _removeImage(File image) {
    setState(() {
      _capturedImages.remove(image);
      _photoOrientations.remove(image);

      if (_previewImage == image) {
        if (_capturedImages.isNotEmpty) {
          _previewImage = _capturedImages.last;
        } else {
          _previewImage = null;
          _isReviewing = false;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _uploadPhotos(BuildContext context) async {
    if (_capturedImages.isEmpty) return;

    try {
      setState(() {
        _isUploading = true;
      });

      for (final image in _capturedImages) {
        await cameraService.uploadIdentificationImage(
          image,
          widget.assessmentId,
        );
      }

      // Show success message and pop
      if (mounted) {
        Navigator.pop(context, 'Images uploaded successfully');
      }
    } catch (e) {
      print('Error uploading images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading images: $e')),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 64,
            color: Colors.black54,
          ),
          SizedBox(height: 16),
          Text(
            'Document Scanner',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the scan button to start scanning documents',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _scanDocument,
            icon: Icon(Icons.document_scanner),
            label: Text('Scan Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_previewImage == null) return Container();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final imageWidth = screenWidth * 0.85;
        final imageHeight = imageWidth * 1.4;

        return Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 40,
              left: (screenWidth - imageWidth) / 2,
              child: Container(
                width: imageWidth,
                height: imageHeight,
                color: Colors.transparent,
                child: Transform.rotate(
                  angle: _getRotationAngle(_photoOrientations[_previewImage]!),
                  alignment: Alignment.center,
                  child: ClipRect(
                    child: Image.file(
                      _previewImage!,
                      width: imageWidth,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _removeImage(_previewImage!),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: _returnToCamera,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageThumbnail(File image) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _previewImage = image;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: _previewImage == image
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Transform.rotate(
            angle: _getRotationAngle(_photoOrientations[image]!),
            alignment: Alignment.center,
            child: Image.file(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailList() {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _capturedImages.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return _buildImageThumbnail(_capturedImages[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SnapScore',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'Scan Documents',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_isReviewing && _previewImage != null)
                        _buildImagePreview()
                      else
                        _buildWelcomeScreen(),
                    ],
                  ),
          ),
          // Thumbnail list if we have images
          if (_capturedImages.isNotEmpty) _buildThumbnailList(),
          if (_capturedImages.isNotEmpty && !_isProcessing)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _scanDocument,
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Scan More',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isUploading ? null : () => _uploadPhotos(context),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Upload All',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          if (_capturedImages.isEmpty && !_isReviewing && !_isProcessing)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: TextButton(
                onPressed: _scanDocument,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Scan Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
