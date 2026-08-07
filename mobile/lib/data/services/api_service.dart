import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image/image.dart' as img;

class IdentifyResult {
  final bool success;
  final bool isNewUnlock;
  final bool isDuplicate;
  final Map<String, dynamic>? plant;
  final String? userPhotoUrl;
  final int xpEarned;
  final List<Map<String, dynamic>> achievementsEarned;
  final Map<String, dynamic>? userStats;
  final double confidence;
  final String matchStatus;
  final String? messageEn;
  final String? messageKh;
  final bool isFlagged;
  final String? error;
  final Map<String, dynamic>? safetyInfo;

  IdentifyResult({
    required this.success,
    this.isNewUnlock = false,
    this.isDuplicate = false,
    this.plant,
    this.userPhotoUrl,
    this.xpEarned = 0,
    this.achievementsEarned = const [],
    this.userStats,
    this.confidence = 0,
    this.matchStatus = 'unmatched',
    this.messageEn,
    this.messageKh,
    this.isFlagged = false,
    this.error,
    this.safetyInfo,
  });

  factory IdentifyResult.fromJson(Map<String, dynamic> json) {
    return IdentifyResult(
      success: json['success'] ?? false,
      isNewUnlock: json['is_new_unlock'] ?? false,
      isDuplicate: json['is_duplicate'] ?? false,
      plant: json['plant'],
      userPhotoUrl: json['user_photo_url'],
      xpEarned: json['xp_earned'] ?? 0,
      achievementsEarned: List<Map<String, dynamic>>.from(json['achievements_earned'] ?? []),
      userStats: json['user_stats'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      matchStatus: json['match_status'] ?? 'unmatched',
      messageEn: json['message_en'],
      messageKh: json['message_kh'],
      isFlagged: json['is_flagged'] ?? false,
      error: json['error'],
      safetyInfo: json['safety_info'],
    );
  }
}

class ApiService {
  static const _baseUrl = 'https://us-central1-urplant-app.cloudfunctions.net';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 45),
  ));

  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      return token ?? '';
    }
    final cred = await FirebaseAuth.instance.signInAnonymously();
    final token = await cred.user!.getIdToken();
    return token ?? '';
  }

  Future<IdentifyResult> identifyPlant(Uint8List imageBytes, String? exifData) async {
    try {
      final token = await _getIdToken();

      // Compress image
      final decoded = img.decodeImage(imageBytes);
      if (decoded != null) {
        final resized = img.copyResize(decoded, width: 1024);
        imageBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 80));
      }

      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: 'plant.jpg'),
        'exif_data': exifData ?? '{}',
      });

      final response = await _dio.post(
        '/identifyPlant',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return IdentifyResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return IdentifyResult.fromJson(e.response!.data);
      }
      return IdentifyResult(success: false, error: e.message ?? 'Network error');
    }
  }
}