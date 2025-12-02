import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  // Simple encryption key (in a real app, this should be securely managed)
  static const String _encryptionKey = 'my32lengthsupersecretnooneknows1';

  // Encrypt sensitive data
  String encryptData(String plainText) {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      return '${encrypted.base64}:${iv.base64}';
    } catch (e) {
      print('Encryption error: $e');
      return plainText; // Return original if encryption fails
    }
  }

  // Decrypt sensitive data
  String decryptData(String encryptedData) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) return encryptedData;

      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final iv = encrypt.IV.fromBase64(parts[1]);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decrypted = encrypter.decrypt64(parts[0], iv: iv);
      return decrypted;
    } catch (e) {
      print('Decryption error: $e');
      return encryptedData; // Return original if decryption fails
    }
  }

  // Hash sensitive data (for passwords, etc.)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate secure token
  String generateSecureToken() {
    final random = encrypt.Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  // Validate token format
  bool isValidToken(String token) {
    try {
      base64Url.decode(token);
      return token.length >= 32; // Minimum length check
    } catch (e) {
      return false;
    }
  }

  // API access control
  bool hasAccess(String userRole, String requiredRole) {
    final accessHierarchy = {'student': 1, 'teacher': 2, 'admin': 3};

    final userLevel = accessHierarchy[userRole] ?? 0;
    final requiredLevel = accessHierarchy[requiredRole] ?? 0;

    return userLevel >= requiredLevel;
  }

  // Check if user can access specific resource
  bool canAccessResource(String userRole, String resource, String action) {
    // Define access control matrix
    final accessControl = {
      'student': {
        'attendance': ['read_own'],
        'profile': ['read', 'update'],
      },
      'teacher': {
        'attendance': ['read', 'create', 'update'],
        'students': ['read'],
        'classes': ['read', 'create', 'update'],
      },
      'admin': {
        'attendance': ['read', 'create', 'update', 'delete'],
        'students': ['read', 'create', 'update', 'delete'],
        'classes': ['read', 'create', 'update', 'delete'],
        'users': ['read', 'create', 'update', 'delete'],
      },
    };

    final userPermissions = accessControl[userRole];
    if (userPermissions == null) return false;

    final resourcePermissions = userPermissions[resource];
    if (resourcePermissions == null) return false;

    return resourcePermissions.contains(action) ||
        resourcePermissions.contains('*'); // Wildcard for all actions
  }
}
