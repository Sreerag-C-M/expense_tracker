import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/utils/api_constants.dart';

class UpcomingProvider {
  Future<List<dynamic>> getUpcomingPayments() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/upcoming-payments'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load upcoming payments');
    }
  }

  Future<void> createUpcomingPayment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/upcoming-payments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create upcoming payment');
    }
  }

  Future<void> deleteUpcomingPayment(String id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/upcoming-payments/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete upcoming payment');
    }
  }
}
