import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/ambience_model.dart';

class AmbienceRepository {
  Future<List<AmbienceModel>> getAmbiences() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/ambiences.json');
      final jsonData = jsonDecode(jsonString) as List;
      return jsonData
          .map((item) => AmbienceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load ambiences: $e');
    }
  }

  Future<AmbienceModel> getAmbienceById(String id) async {
    final ambiences = await getAmbiences();
    try {
      return ambiences.firstWhere((ambience) => ambience.id == id);
    } catch (e) {
      throw Exception('Ambience not found');
    }
  }
}