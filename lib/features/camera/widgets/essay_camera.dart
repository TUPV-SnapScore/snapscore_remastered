// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snapscore/core/themes/colors.dart';
import 'package:snapscore/features/camera/services/camera_service.dart';

class EssayCamera extends StatefulWidget {
  final String assessmentName;
  final String assessmentId;

  const EssayCamera(
      {super.key, required this.assessmentName, required this.assessmentId});

  @override
  EssayCameraState createState() => EssayCameraState();
}

class EssayCameraState extends State<EssayCamera> {
  CameraController? _controller;
  final List<File> _capturedImages = [];
  File? _previewImage; // Currently displayed image in review mode
  bool _isProcessing = false;
  bool _isReviewing = false;
  bool _isUploading = false;
  FlashMode _currentFlashMode = FlashMode.off;
  final cameraService = CameraService();

  DeviceOrientation _currentOrientation = DeviceOrientation.portraitUp;
  final Map<File, DeviceOrientation> _photoOrientations = {};

  double? _cameraAspectRatio;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(cameras[0], ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      // Set aspect ratio after initialization
      setState(() {
        _cameraAspectRatio = _controller!.value.aspectRatio;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _updateCameraOrientation(DeviceOrientation orientation) async {
    if (_controller == null) return;

    setState(() {
      _currentOrientation = orientation;
    });

    try {
      await _controller!.lockCaptureOrientation(orientation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error changing orientation: $e')),
        );
      }
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    if (!(_controller?.value.isInitialized ?? false)) return;

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
      return;
    }

    try {
      setState(() => _isProcessing = true);

      // Set focus and exposure for best quality
      await _controller!.setExposureMode(ExposureMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${appDir.path}/Pictures';
      await Directory(dirPath).create(recursive: true);

      // Use PNG extension for lossless quality
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String tempImagePath = '$dirPath${Platform.pathSeparator}$fileName';

      // Take picture with maximum quality
      final XFile image = await _controller!.takePicture();

      // Copy to new location as PNG
      final File originalFile = File(image.path);
      await originalFile.copy(tempImagePath);

      final File capturedImage = File(tempImagePath);

      setState(() {
        _capturedImages.add(capturedImage);
        _photoOrientations[capturedImage] = _currentOrientation;
        _previewImage = capturedImage;
        _isProcessing = false;
        _isReviewing = true;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
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

  void _rotateToNext() async {
    final orientations = [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
    ];

    final currentIndex = orientations.indexOf(_currentOrientation);
    final nextOrientation =
        orientations[(currentIndex + 1) % orientations.length];

    await _updateCameraOrientation(nextOrientation);
  }

  void _toggleFlash() async {
    if (_controller == null) return;

    try {
      FlashMode nextMode;
      switch (_currentFlashMode) {
        case FlashMode.off:
          nextMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          nextMode = FlashMode.always;
          break;
        default:
          nextMode = FlashMode.off;
      }

      await _controller!.setFlashMode(nextMode);
      setState(() => _currentFlashMode = nextMode);
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error changing flash mode: $e')),
      );
    }
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _uploadPhotos(BuildContext context) async {
    if (_capturedImages.isEmpty) return;

    try {
      setState(() {
        _isUploading = true;
      });

      // Upload each image one by one
      for (final image in _capturedImages) {
        await cameraService.uploadEssayImage(
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

  Widget _buildCornerMarker() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.withOpacity(0.8), width: 3),
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_controller?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use full width of the screen
        final width = constraints.maxWidth * 0.8;
        // Calculate height for 16:9 aspect ratio
        final height = width * 16 / 9;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera preview
              SizedBox(
                width: width,
                height: height,
                child: CameraPreview(_controller!),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_previewImage == null) return Container();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final imageWidth = screenWidth * 1.5;
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
                    Icons.camera_alt,
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
    return SizedBox(
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
          if (!_isReviewing || _previewImage == null) ...[
            IconButton(
              icon: Icon(_getFlashIcon(), color: Colors.black),
              onPressed: _toggleFlash,
            ),
            IconButton(
              icon: const Icon(Icons.screen_rotation, color: Colors.black),
              onPressed: _rotateToNext,
            ),
          ],
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
              'Scan',
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
                      else if (_controller?.value.isInitialized ?? false)
                        _buildCameraPreview(),
                      if (!_isReviewing || _previewImage == null) ...[
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () => {_captureImage(context)},
                              child: Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          // Thumbnail list if we have images
          if (_capturedImages.isNotEmpty) _buildThumbnailList(),
          if (_capturedImages.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextButton(
                onPressed: _isUploading ? null : () => {_uploadPhotos(context)},
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                        ),
                      )
                    : const Text(
                        'Upload All Images',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
