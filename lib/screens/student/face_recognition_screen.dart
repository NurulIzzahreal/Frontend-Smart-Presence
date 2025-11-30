import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:frontend_smart_presence/services/attendance_service.dart';
import 'package:frontend_smart_presence/utils/permissions.dart';

class FaceRecognitionScreen extends StatefulWidget {
  final String studentId;
  final String classId;

  const FaceRecognitionScreen({
    super.key,
    required this.studentId,
    required this.classId,
  });

  @override
  State<FaceRecognitionScreen> createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Check camera permission
    final hasPermission = await Permissions.requestCameraPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required for face recognition'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    // Get available cameras
    _cameras = await availableCameras();
    if (_cameras!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No camera found on this device'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    // Initialize camera controller
    _controller = CameraController(
      _cameras![0], // Use the first camera (usually rear camera)
      ResolutionPreset.medium,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to initialize camera'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Capture image
      final XFile image = await _controller!.takePicture();

      setState(() {
        _capturedImage = image;
        _isProcessing = false;
      });

      // Process the captured image for attendance
      await _processAttendance(image);
    } catch (e) {
      print('Error capturing image: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to capture image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processAttendance(XFile image) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Read image bytes
      final imageBytes = await image.readAsBytes();

      // Send to attendance service
      final attendanceService = AttendanceService();
      final attendance = await attendanceService
          .markAttendanceWithFaceRecognition(
            widget.studentId,
            widget.classId,
            imageBytes,
          );

      setState(() {
        _isProcessing = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance marked successfully! Status: ${attendance.status}, Confidence: ${attendance.confidenceScore.toStringAsFixed(2)}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after a delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error processing attendance: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller == null || !_controller!.value.isInitialized
                ? const Center(child: Text('Initializing camera...'))
                : CameraPreview(_controller!),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Processing...'),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _isProcessing ? null : _captureImage,
                  child: const Icon(Icons.camera),
                ),
                if (_capturedImage != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _capturedImage = null;
                      });
                    },
                    child: const Text('Retake'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
