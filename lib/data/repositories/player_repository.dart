import 'package:hive/hive.dart';
import '../models/session_model.dart';

import 'dart:convert';

class PlayerRepository {
  late Box<String> _sessionBox;

  Future<void> initialize() async {
    _sessionBox = Hive.box<String>('session_state');
  }

  Future<void> saveSessionState(SessionModel session) async {
    await _sessionBox.put('active_session', jsonEncode(session.toJson()));
  }

  SessionModel? getSessionState() {
    final jsonString = _sessionBox.get('active_session');
    if (jsonString == null) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return SessionModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSessionState() async {
    await _sessionBox.delete('active_session');
  }
}

