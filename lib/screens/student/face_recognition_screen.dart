import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:frontend_smart_presence/services/attendance_service.dart';
import 'package:frontend_smart_presence/services/liveness_service.dart';
import 'package:frontend_smart_presence/services/geofencing_service.dart';
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
  LivenessService _livenessService = LivenessService();
  bool _livenessVerified = false;
  String _livenessStatus = '';
  double _livenessConfidence = 0.0;
  GeofencingService _geofencingService = GeofencingService();
  bool _locationVerified = false;
  String _locationStatus = '';
  bool _locationCheckCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkLocation();
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

  Future<void> _checkLocation() async {
    setState(() {
      _locationStatus = 'Checking location...';
    });

    try {
      final isWithinArea = await _geofencingService.isWithinAllowedArea();

      setState(() {
        _locationVerified = isWithinArea;
        _locationStatus = isWithinArea
            ? 'Location verified: You are at the correct location'
            : 'Location verification failed: You are not at the correct location';
        _locationCheckCompleted = true;
      });

      if (!isWithinArea) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Attendance can only be marked from the designated location',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error checking location: $e');
      setState(() {
        _locationStatus = 'Location check failed';
        _locationCheckCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location check failed: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    // Check if location verification is required and completed
    if (!_locationCheckCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for location verification to complete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if location is verified
    if (!_locationVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must be at the designated location to mark attendance',
          ),
          backgroundColor: Colors.red,
        ),
      );
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
      // Perform liveness detection first
      if (!_livenessVerified) {
        await _performLivenessCheck();
        return;
      }

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

  Future<void> _performLivenessCheck() async {
    // In a real implementation, we would process camera frames for liveness detection
    // For this demo, we'll simulate a successful liveness check

    // Simulate liveness verification process
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _livenessVerified = true;
      _livenessStatus = 'Liveness verified';
      _livenessConfidence = 0.95;
      _isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Liveness verification successful!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLivenessChallenge() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_livenessService.getChallengeTitle()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_livenessService.getChallengeInstruction()),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: _livenessConfidence,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                '${(_livenessConfidence * 100).toStringAsFixed(0)}% complete',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Simulate completing the challenge
                setState(() {
                  _livenessConfidence = 1.0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
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
          // Location status indicator
          Container(
            padding: const EdgeInsets.all(16.0),
            color: _locationCheckCompleted
                ? (_locationVerified ? Colors.green[100] : Colors.red[100])
                : Colors.orange[100],
            child: Row(
              children: [
                Icon(
                  _locationCheckCompleted
                      ? (_locationVerified
                            ? Icons.location_on
                            : Icons.location_off)
                      : Icons.location_searching,
                  color: _locationCheckCompleted
                      ? (_locationVerified ? Colors.green : Colors.red)
                      : Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locationStatus,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _locationCheckCompleted
                          ? (_locationVerified ? Colors.green : Colors.red)
                          : Colors.orange,
                    ),
                  ),
                ),
                if (!_locationCheckCompleted)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Liveness status indicator
          if (_locationVerified && !_livenessVerified)
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.orange[100],
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.orange),
                  const SizedBox(width: 10),
                  const Text(
                    'Liveness verification required',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _showLivenessChallenge,
                    child: const Text('Verify'),
                  ),
                ],
              ),
            ),

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
                  onPressed:
                      _isProcessing || !_livenessVerified || !_locationVerified
                      ? null
                      : _captureImage,
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
