import 'dart:math';
import 'package:camera/camera.dart';

class LivenessDetectionResult {
  final bool isLive;
  final String challengeType;
  final double confidence;

  LivenessDetectionResult({
    required this.isLive,
    required this.challengeType,
    required this.confidence,
  });
}

class LivenessService {
  // Eye blink detection variables
  double? _lastEyeAspectRatio;
  int _blinkCount = 0;
  final int _requiredBlinks = 2;
  final double _blinkThreshold = 0.3;

  // Head movement detection
  double? _lastHeadAngle;
  final List<double> _headMovements = [];
  final int _requiredHeadMovements = 3;

  // Challenge sequence
  final List<String> _challenges = [
    'blink', // Eye blink challenge
    'turn_left', // Turn head left
    'smile', // Smile challenge
    'turn_right', // Turn head right
  ];

  int _currentChallengeIndex = 0;
  String get currentChallenge => _challenges[_currentChallengeIndex];

  // Simulate eye aspect ratio calculation (in a real implementation, this would use ML)
  double _calculateEyeAspectRatio() {
    // This is a simplified simulation
    // In a real implementation, you would use facial landmark detection
    return 0.2 + (Random().nextDouble() * 0.4);
  }

  // Simulate head angle calculation (in a real implementation, this would use ML)
  double _calculateHeadAngle() {
    // This is a simplified simulation
    // In a real implementation, you would use facial orientation detection
    return -30 + (Random().nextDouble() * 60); // -30 to 30 degrees
  }

  // Simulate smile detection (in a real implementation, this would use ML)
  bool _detectSmile() {
    // This is a simplified simulation
    // In a real implementation, you would use mouth landmark detection
    return Random().nextDouble() > 0.7;
  }

  // Process a camera frame for liveness detection
  LivenessDetectionResult processFrame(CameraImage image) {
    switch (_currentChallengeIndex) {
      case 0: // Eye blink challenge
        return _processBlinkChallenge();
      case 1: // Turn head left
        return _processHeadTurnChallenge(-1);
      case 2: // Smile challenge
        return _processSmileChallenge();
      case 3: // Turn head right
        return _processHeadTurnChallenge(1);
      default:
        return LivenessDetectionResult(
          isLive: false,
          challengeType: 'unknown',
          confidence: 0.0,
        );
    }
  }

  LivenessDetectionResult _processBlinkChallenge() {
    final eyeAspectRatio = _calculateEyeAspectRatio();

    if (_lastEyeAspectRatio != null) {
      // Detect blink by rapid change in eye aspect ratio
      if (_lastEyeAspectRatio! > _blinkThreshold &&
          eyeAspectRatio <= _blinkThreshold) {
        _blinkCount++;
      }
    }

    _lastEyeAspectRatio = eyeAspectRatio;

    final isLive = _blinkCount >= _requiredBlinks;
    final confidence = (_blinkCount / _requiredBlinks).clamp(0.0, 1.0);

    return LivenessDetectionResult(
      isLive: isLive,
      challengeType: 'blink',
      confidence: confidence,
    );
  }

  LivenessDetectionResult _processHeadTurnChallenge(int direction) {
    final headAngle = _calculateHeadAngle();

    if (_lastHeadAngle != null) {
      final angleChange = headAngle - _lastHeadAngle!;

      // Check if head turned in the required direction
      if ((direction == -1 && angleChange < -10) ||
          (direction == 1 && angleChange > 10)) {
        _headMovements.add(angleChange);
      }
    }

    _lastHeadAngle = headAngle;

    final isLive = _headMovements.length >= _requiredHeadMovements;
    final confidence = (_headMovements.length / _requiredHeadMovements).clamp(
      0.0,
      1.0,
    );

    return LivenessDetectionResult(
      isLive: isLive,
      challengeType: direction == -1 ? 'turn_left' : 'turn_right',
      confidence: confidence,
    );
  }

  LivenessDetectionResult _processSmileChallenge() {
    final isSmiling = _detectSmile();
    final confidence = isSmiling ? 1.0 : 0.0;

    return LivenessDetectionResult(
      isLive: isSmiling,
      challengeType: 'smile',
      confidence: confidence,
    );
  }

  // Move to the next challenge
  void nextChallenge() {
    if (_currentChallengeIndex < _challenges.length - 1) {
      _currentChallengeIndex++;
      _resetChallengeState();
    }
  }

  // Reset challenge state
  void _resetChallengeState() {
    _blinkCount = 0;
    _lastEyeAspectRatio = null;
    _lastHeadAngle = null;
    _headMovements.clear();
  }

  // Check if all challenges are completed
  bool get isAllChallengesCompleted =>
      _currentChallengeIndex >= _challenges.length - 1;

  // Reset the entire liveness detection process
  void reset() {
    _currentChallengeIndex = 0;
    _resetChallengeState();
  }

  // Get challenge instructions for UI
  String getChallengeInstruction() {
    switch (currentChallenge) {
      case 'blink':
        return 'Blink your eyes $_requiredBlinks times';
      case 'turn_left':
        return 'Turn your head to the left';
      case 'smile':
        return 'Please smile';
      case 'turn_right':
        return 'Turn your head to the right';
      default:
        return 'Follow the instructions';
    }
  }

  // Get challenge title for UI
  String getChallengeTitle() {
    switch (currentChallenge) {
      case 'blink':
        return 'Eye Blink Detection';
      case 'turn_left':
        return 'Head Turn Left';
      case 'smile':
        return 'Smile Detection';
      case 'turn_right':
        return 'Head Turn Right';
      default:
        return 'Liveness Challenge';
    }
  }
}
