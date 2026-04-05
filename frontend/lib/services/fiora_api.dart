import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_token_store.dart';

/// HTTP client for Fiora FastAPI (`/api/v1`).
class FioraApi {
  FioraApi({String? baseUrl}) : baseUrl = baseUrl ?? kFioraApiBase;

  final String baseUrl;

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _jsonHeaders(String? token) {
    final h = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────────────────

  /// POST /auth/signup — full health profile creation.
  /// Called by SignupScreen; stores JWT in SharedPreferences on success.
  Future<String> signup({
    required String name,
    required int age,
    required String email,
    required String password,
    int? cycleLength,
    required int avgPeriodLength,
    required List<String> knownConditions,
    required String emergencyContact,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'age': age,
      'email': email,
      'password': password,
      'avg_period_length': avgPeriodLength,
      'known_conditions': knownConditions,
      'emergency_contact': emergencyContact,
    };
    if (cycleLength != null) {
      body['cycle_length'] = cycleLength;
    }
    final res = await http.post(
      _u('/api/v1/auth/signup'),
      headers: _jsonHeaders(null),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw FioraApiException(res.statusCode, 'Missing access_token');
    }
    await AuthTokenStore.save(token);
    return token;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIX: login() — was completely missing from the original fiora_api.dart.
  //
  // The "Already have an account? Login" link on LoginPage used to open
  // SignupScreen instead of a login form. There was also no login() method
  // here for a real login form to call.
  //
  // Now: POST /auth/login → store JWT → return token.
  // ─────────────────────────────────────────────────────────────────────────
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      _u('/api/v1/auth/login'),
      headers: _jsonHeaders(null),
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw FioraApiException(res.statusCode, 'Missing access_token');
    }
    await AuthTokenStore.save(token);
    return token;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MAGIC SIGNUP
  // ─────────────────────────────────────────────────────────────────────────

  /// POST /auth/magic_signup — Magic.link registration with full health profile.
  ///
  /// [didToken] comes from Magic.instance.user.getIdToken() after the user
  /// completes the email OTP flow. The backend validates it with the
  /// MAGIC_SECRET_KEY, creates the user + profile, and returns a Fiora JWT.
  Future<String> magicSignup({
    required String didToken,
    required String name,
    required int age,
    int? cycleLength,
    required int avgPeriodLength,
    required List<String> knownConditions,
    required String emergencyContact,
  }) async {
    final body = <String, dynamic>{
      'did_token': didToken,
      'name': name,
      'age': age,
      'avg_period_length': avgPeriodLength,
      'known_conditions': knownConditions,
      'emergency_contact': emergencyContact,
    };
    if (cycleLength != null) body['cycle_length'] = cycleLength;

    final res = await http.post(
      _u('/api/v1/auth/magic_signup'),
      headers: _jsonHeaders(null),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw FioraApiException(res.statusCode, 'Missing access_token');
    }
    await AuthTokenStore.save(token);
    return token;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILE
  // ─────────────────────────────────────────────────────────────────────────

  /// GET /profiles/me — user row + profile (includes `name` from signup).
  Future<Map<String, dynamic>> fetchProfileMe() async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final res = await http.get(
      _u('/api/v1/profiles/me'),
      headers: _jsonHeaders(token),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIX: patchProfileInfo() — was completely missing from the original file.
  //
  // InfoPage's "Save Profile" button used to call Navigator.pushNamed()
  // immediately without any API call, discarding all user input.
  //
  // Now: PATCH /profiles/me with health fields from InfoPage.
  // The backend's ProfileUpdate schema accepts these optional fields; we only
  // send the ones that have real values.
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> patchProfileInfo({
    double? heightCm,
    double? weightKg,
    String? lastPeriodDateIso, // "YYYY-MM-DD"
    int? flowRating,
    String? mood,
    List<String>? symptoms,
  }) async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final body = <String, dynamic>{};
    if (heightCm != null) body['height_cm'] = heightCm;
    if (weightKg != null) body['weight_kg'] = weightKg;
    if (lastPeriodDateIso != null) body['last_period_date'] = lastPeriodDateIso;
    if (flowRating != null) body['flow_rating'] = flowRating;
    if (mood != null) body['mood'] = mood;
    if (symptoms != null) body['initial_symptoms'] = symptoms;

    final res = await http.patch(
      _u('/api/v1/profiles/me'),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PERIOD LOGGING
  // ─────────────────────────────────────────────────────────────────────────

  /// POST /periods — daily log; returns decoded JSON including optional severe_cramps.
  Future<Map<String, dynamic>> postPeriodLog({
    required String dateIso, // YYYY-MM-DD
    required String flow,
    required List<String> symptoms,
    required int painLevel,
  }) async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final res = await http.post(
      _u('/api/v1/periods'),
      headers: _jsonHeaders(token),
      body: jsonEncode({
        'date': dateIso,
        'flow': flow,
        'symptoms': symptoms,
        'pain_level': painLevel,
      }),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIX: analyzeHealth() — was completely missing from the original file.
  //
  // HomeScreen's _aiInsight() widget displayed a single hardcoded string:
  //   "Your cortisol levels typically peak in 2 hours..."
  // It never called any backend endpoint.
  //
  // Now: POST /health_analysis/analyze → returns ML anomaly + insight JSON.
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> analyzeHealth({int windowDays = 7}) async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final res = await http.post(
      _u('/api/v1/health_analysis/analyze'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'window_days': windowDays}),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ALERTS
  // ─────────────────────────────────────────────────────────────────────────

  /// GET /alerts — health notifications for current user.
  Future<List<Map<String, dynamic>>> fetchAlerts() async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final res = await http.get(
      _u('/api/v1/alerts'),
      headers: _jsonHeaders(token),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final items = map['items'] as List<dynamic>? ?? [];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  // ─────────────────────────────────────────────────────────────────────────
  // WEARABLE DATA (FASTAPI INTEGRATION)
  // ─────────────────────────────────────────────────────────────────────────

  /// POST /wearables/sync-mock — generates mock smartwatch data internally.
  Future<Map<String, dynamic>> syncMockSmartwatch() async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final res = await http.post(
      _u('/api/v1/wearables/sync-mock'),
      headers: _jsonHeaders(token),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// GET /wearables/events
  Future<List<Map<String, dynamic>>> fetchWearableEvents() async {
    final token = await AuthTokenStore.read();
    if (token == null) {
      throw FioraApiException(401, 'Not signed in');
    }
    final res = await http.get(
      _u('/api/v1/wearables/events?limit=100'),
      headers: _jsonHeaders(token),
    );
    if (res.statusCode != 200) {
      throw FioraApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final items = map['items'] as List<dynamic>? ?? [];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}

class FioraApiException implements Exception {
  FioraApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'FioraApiException($statusCode): $body';
}
