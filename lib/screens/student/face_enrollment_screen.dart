import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:frontend_smart_presence/services/student_service.dart';
import 'package:frontend_smart_presence/models/student.dart';
import 'package:frontend_smart_presence/utils/permissions.dart';

class FaceEnrollmentScreen extends StatefulWidget {
  final Student student;

  const FaceEnrollmentScreen({super.key, required this.student});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;
  XFile? _capturedImage;
  int _enrollmentStep =
      1; // Step 1: Front view, Step 2: Left view, Step 3: Right view
  List<XFile> _enrollmentImages = [];

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
          content: Text('Camera permission is required for face enrollment'),
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

      // Add to enrollment images
      _enrollmentImages.add(image);

      // Move to next step or finish enrollment
      if (_enrollmentStep < 3) {
        setState(() {
          _enrollmentStep++;
        });
      } else {
        // Process enrollment
        await _processEnrollment();
      }
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

  Future<void> _processEnrollment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // In a real implementation, we would send the images to the backend
      // for face encoding and storage. For now, we'll just simulate this.

      // Update student with face encoding (simulated)
      final studentService = StudentService();
      final updatedStudent = Student(
        id: widget.student.id,
        name: widget.student.name,
        email: widget.student.email,
        studentId: widget.student.studentId,
        className: widget.student.className,
        faceEncoding:
            'encoded_face_data_${DateTime.now().millisecondsSinceEpoch}',
      );

      await studentService.updateStudent(widget.student.id, updatedStudent);

      setState(() {
        _isProcessing = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Face enrollment completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after a delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(
          context,
          true,
        ); // Return true to indicate successful enrollment
      }
    } catch (e) {
      print('Error processing enrollment: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process enrollment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getInstructionText() {
    switch (_enrollmentStep) {
      case 1:
        return 'Position your face in the center of the frame and look directly at the camera';
      case 2:
        return 'Turn your head slightly to the left and hold still';
      case 3:
        return 'Turn your head slightly to the right and hold still';
      default:
        return '';
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
        title: const Text('Face Enrollment'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Instruction text
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _getInstructionText(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: _enrollmentStep / 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Step counter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Step $_enrollmentStep of 3'),
          ),

          // Camera preview
          Expanded(
            child: _controller == null || !_controller!.value.isInitialized
                ? const Center(child: Text('Initializing camera...'))
                : CameraPreview(_controller!),
          ),

          // Processing indicator
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

          // Capture button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _isProcessing ? null : _captureImage,
                  child: const Icon(Icons.camera),
                ),
                if (_capturedImage != null && _enrollmentStep < 3)
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
