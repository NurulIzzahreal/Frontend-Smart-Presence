import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl =
      'http://localhost:8000/api'; // Change to your backend URL
  static const String loginEndpoint = '$baseUrl/auth/login';

  String? _token;
  User? _currentUser;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? get token => _token;
  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse(loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> studentLogin(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/student-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Student login error: $e');
      return false;
    }
  }

  Future<bool> requestOTP(String studentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('OTP request error: $e');
      return false;
    }
  }

  Future<bool> verifyOTP(String studentId, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_currentUser!.toJson()));

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('OTP verification error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      _token = token;
      _currentUser = User.fromJson(jsonDecode(userJson));
      return true;
    }

    return false;
  }
}
