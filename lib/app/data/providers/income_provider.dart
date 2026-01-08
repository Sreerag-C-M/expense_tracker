import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

class IncomeProvider {
  Future<void> createIncome(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/income'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create income');
    }
  }
}
