import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

class DashboardProvider {
  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/dashboard'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load dashboard data');
    }
  }
}
